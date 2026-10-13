import { query } from '@anthropic-ai/claude-agent-sdk';
import { parseArgs, ArgsError, USAGE } from './args.js';
import { formatMessage } from './format.js';
import { createPermissionHandler } from './permissions.js';
import { runRepl } from './repl.js';
import { loadConfig } from './config.js';
import { loadStore, saveStore, getProject, recordSession, addApproval } from './store.js';

async function readStdin() {
  process.stdin.setEncoding('utf8');
  let data = '';
  for await (const chunk of process.stdin) data += chunk;
  return data.trim();
}

function exitCodeForResult(message) {
  if (message.type !== 'result') return 0;
  if (message.subtype === 'success' && !message.is_error) return 0;
  return 1;
}

export async function main(argv = process.argv.slice(2)) {
  let args;
  try {
    args = parseArgs(argv);
  } catch (err) {
    if (err instanceof ArgsError) {
      process.stderr.write(`${err.message}\n\n${USAGE}`);
      return 2;
    }
    throw err;
  }

  if (args.help) {
    process.stdout.write(USAGE);
    return 0;
  }

  // Bare `clp` at a real terminal has nothing else useful to do with no
  // prompt, so it drops into a conversation instead of erroring.
  const interactive = args.interactive || (!args.prompt && process.stdin.isTTY);

  let prompt = args.prompt;
  if (!interactive) {
    if (!prompt) {
      if (process.stdin.isTTY) {
        process.stderr.write(`No prompt provided.\n\n${USAGE}`);
        return 2;
      }
      prompt = await readStdin();
    }
    if (!prompt) {
      process.stderr.write(`Empty prompt.\n\n${USAGE}`);
      return 2;
    }
  }

  const config = loadConfig();
  const verbose = args.verbose || config.verbose;
  const project = process.cwd();
  const store = loadStore();
  const projectState = getProject(store, project);

  let resume;
  if (args.sessionId) {
    resume = args.sessionId;
  } else if (args.resume) {
    if (!projectState.lastSessionId) {
      process.stderr.write('No previous session found for this project. Run clp without --resume to start one.\n');
      return 1;
    }
    resume = projectState.lastSessionId;
  }

  const approvals = new Set(projectState.approvals);

  const canUseTool = createPermissionHandler({
    approvals,
    nonInteractiveDefault: config.nonInteractiveDefault,
    out: process.stdout,
    onAlwaysAllow: (patternKey) => {
      addApproval(store, project, patternKey);
      saveStore(store);
    },
  });

  if (args.allowAll) {
    process.stdout.write('⚠ --allow-all: permission prompts are disabled for this run.\n');
  }
  const permissionOptions = args.allowAll
    ? { permissionMode: 'bypassPermissions', allowDangerouslySkipPermissions: true }
    : { permissionMode: 'default', canUseTool };

  if (interactive) {
    return runRepl({
      initialPrompt: prompt,
      project,
      resume,
      permissionOptions,
      config,
      verbose,
      store,
      out: process.stdout,
    });
  }

  const abortController = new AbortController();
  const sdkQuery = query({
    prompt,
    options: {
      cwd: project,
      settingSources: ['user', 'project', 'local'],
      abortController,
      ...permissionOptions,
      ...(resume ? { resume } : {}),
    },
  });

  let interrupting = false;
  const onSigint = () => {
    if (interrupting) {
      process.stderr.write('\nForce exiting.\n');
      process.exit(130);
    }
    interrupting = true;
    process.stderr.write('\nInterrupting… (press Ctrl+C again to force exit)\n');
    sdkQuery.interrupt().catch(() => {});
  };
  process.on('SIGINT', onSigint);

  let exitCode = 0;
  let sessionId;

  try {
    for await (const message of sdkQuery) {
      if (typeof message.session_id === 'string') {
        sessionId = message.session_id;
      }
      formatMessage(message, { verbose, truncateLength: config.truncateLength, out: process.stdout });
      if (message.type === 'result') {
        exitCode = exitCodeForResult(message);
      }
    }
  } finally {
    process.removeListener('SIGINT', onSigint);
  }

  if (interrupting) {
    exitCode = 130;
  }

  if (sessionId) {
    recordSession(store, project, { sessionId, prompt, timestamp: new Date().toISOString() });
    saveStore(store);
  }

  return exitCode;
}
