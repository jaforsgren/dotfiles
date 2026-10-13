import { readTtyKey, CtrlCError } from './tty-prompt.js';

/**
 * Collapses a tool call into a pattern key used for "always allow" matching.
 * Bash is special-cased on its leading command word so "always allow" grants
 * e.g. "run npm" rather than "run any shell command".
 */
export function toolPatternKey(toolName, input) {
  if (toolName === 'Bash' && typeof input?.command === 'string') {
    const firstWord = input.command.trim().split(/\s+/)[0] || 'Bash';
    return `Bash:${firstWord}`;
  }
  return toolName;
}

function describeToolCall(toolName, input) {
  if (toolName === 'Bash' && typeof input?.command === 'string') {
    return `Bash: ${input.command}`;
  }
  if (typeof input?.file_path === 'string') {
    return `${toolName}: ${input.file_path}`;
  }
  return `${toolName}: ${JSON.stringify(input)}`;
}

/**
 * Builds the SDK's `canUseTool` callback.
 *
 * @param {object} deps
 * @param {Set<string>} deps.approvals - pattern keys already always-allowed (mutated on 'a')
 * @param {(patternKey: string) => void} deps.onAlwaysAllow - persist callback
 * @param {string} deps.nonInteractiveDefault - 'allow' | 'deny' when no TTY is available to prompt
 * @param {NodeJS.WritableStream} deps.out - stream to print the permission prompt to
 */
export function createPermissionHandler({
  approvals,
  onAlwaysAllow,
  nonInteractiveDefault,
  out = process.stdout,
  readKey = readTtyKey,
}) {
  return async function canUseTool(toolName, input, _options) {
    const key = toolPatternKey(toolName, input);

    if (approvals.has(key)) {
      return { behavior: 'allow' };
    }

    out.write(`\n🔒 Permission required\n  ${describeToolCall(toolName, input)}\n\n  [y] Allow  [n] Deny  [a] Always allow\n`);

    let answer;
    try {
      answer = await readKey(['y', 'n', 'a']);
    } catch (err) {
      if (err instanceof CtrlCError) {
        out.write('  Cancelled\n');
      } else {
        out.write(`  Could not read an answer (${err.message}) — denying\n`);
      }
      // Deny this one tool call without the `interrupt` flag: setting it tears
      // down the whole turn with an unhandled-looking SDK error instead of
      // just rejecting this call. A real session-wide cancel goes through
      // Ctrl+C at the process level (see cli.js's SIGINT handler), which
      // calls query.interrupt() directly.
      return { behavior: 'deny', message: 'User denied permission' };
    }

    if (answer === null) {
      // No controlling terminal available (e.g. stdin and stdout both piped, no /dev/tty).
      if (nonInteractiveDefault === 'allow') {
        out.write('  No TTY available — allowing per nonInteractiveDefault config\n');
        return { behavior: 'allow' };
      }
      return {
        behavior: 'deny',
        message: `Permission denied: no controlling terminal available to approve "${toolName}".`,
      };
    }

    if (answer === 'n') {
      out.write('  Denied\n');
      return { behavior: 'deny', message: 'User denied permission' };
    }

    if (answer === 'a') {
      out.write(`  Always allowing "${key}"\n`);
      approvals.add(key);
      onAlwaysAllow(key);
      return { behavior: 'allow' };
    }

    out.write('  Allowed\n');
    return { behavior: 'allow' };
  };
}
