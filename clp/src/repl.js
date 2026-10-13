import readline from 'node:readline/promises';
import { query } from '@anthropic-ai/claude-agent-sdk';
import { formatMessage } from './format.js';
import { recordSession, saveStore } from './store.js';

const EXIT_COMMANDS = new Set(['/exit', '/quit', 'exit', 'quit']);

function userMessage(text) {
  return { type: 'user', message: { role: 'user', content: text }, parent_tool_use_id: null };
}

/**
 * Runs an interactive, multi-turn conversation in one process: Claude's
 * replies stream out as they arrive, and you're prompted for the next line
 * after each turn finishes, so you can answer clarifying questions instead
 * of having to re-invoke the CLI with --resume for every reply.
 *
 * @param {object} deps
 * @param {string|null} deps.initialPrompt - sent as the first turn, if given
 * @param {string} deps.project - cwd for the session
 * @param {string} [deps.resume] - session id to resume
 * @param {import('@anthropic-ai/claude-agent-sdk').CanUseTool} deps.canUseTool
 * @param {{ truncateLength: number }} deps.config
 * @param {boolean} deps.verbose
 * @param {object} deps.store - session/approval store, mutated and saved after each turn
 * @param {NodeJS.WritableStream} [deps.out]
 * @returns {Promise<number>} exit code
 */
export async function runRepl({
  initialPrompt,
  project,
  resume,
  canUseTool,
  config,
  verbose,
  store,
  out = process.stdout,
  queryFn = query,
  stdin = process.stdin,
}) {
  const rl = readline.createInterface({ input: stdin, output: out });
  let quit = false;

  async function* promptStream() {
    let pending = initialPrompt;
    while (!quit) {
      let text;
      if (pending !== null && pending !== undefined) {
        text = pending;
        pending = null;
      } else {
        try {
          text = (await rl.question('> ')).trim();
        } catch {
          // stdin closed (Ctrl+D) while waiting for input — end the
          // conversation cleanly instead of throwing out of the generator.
          quit = true;
          return;
        }
      }
      if (!text) continue;
      if (EXIT_COMMANDS.has(text.toLowerCase())) {
        quit = true;
        return;
      }
      yield userMessage(text);
    }
  }

  out.write('Interactive session — type /exit to quit, Ctrl+C to interrupt a turn.\n');

  const abortController = new AbortController();
  const sdkQuery = queryFn({
    prompt: promptStream(),
    options: {
      cwd: project,
      settingSources: ['user', 'project', 'local'],
      permissionMode: 'default',
      canUseTool,
      abortController,
      ...(resume ? { resume } : {}),
    },
  });

  let turnInProgress = false;
  let interruptRequested = false;
  const onSigint = () => {
    if (turnInProgress) {
      out.write('\nInterrupting…\n');
      interruptRequested = true;
      sdkQuery.interrupt().catch(() => {});
      return;
    }
    out.write('\nExiting.\n');
    quit = true;
    rl.close();
  };
  process.on('SIGINT', onSigint);

  let exitCode = 0;
  let sessionId;
  let announcedSession = false;

  try {
    for await (const message of sdkQuery) {
      if (typeof message.session_id === 'string') {
        sessionId = message.session_id;
      }
      if (message.type === 'assistant') {
        turnInProgress = true;
      }
      // Streaming-input mode re-emits a system/init per turn; only the first
      // is worth showing, the rest would just repeat the same session id.
      if (message.type === 'system' && message.subtype === 'init') {
        if (announcedSession) continue;
        announcedSession = true;
      }
      formatMessage(message, { verbose, truncateLength: config.truncateLength, out });
      if (message.type === 'result') {
        turnInProgress = false;
        exitCode = interruptRequested ? 130 : message.subtype === 'success' && !message.is_error ? 0 : 1;
        interruptRequested = false;
        if (sessionId) {
          recordSession(store, project, {
            sessionId,
            prompt: initialPrompt || '(interactive session)',
            timestamp: new Date().toISOString(),
          });
          saveStore(store);
        }
      }
    }
  } catch (err) {
    // Reaching here means the prompt stream ended uncleanly (e.g. the SDK
    // treats stdin closing mid-turn as an aborted operation) rather than
    // via the plain `return` path above — report it, don't crash the CLI.
    if (!quit) {
      out.write(`\n✖ ${err?.message ?? err}\n`);
      exitCode = 1;
    }
  } finally {
    process.removeListener('SIGINT', onSigint);
    rl.close();
  }

  return exitCode;
}
