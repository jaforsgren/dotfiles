export const USAGE = `Usage: clp [options] "<prompt>"

Options:
  --resume            Resume the most recent session for this project
  --session <id>      Resume a specific session by id
  --verbose, -v        Show detailed event output
  --help, -h           Show this help

Examples:
  clp "Fix the failing tests"
  clp --resume "Continue fixing the tests"
  clp --session abc123 "Continue working"
  echo "Fix the lint errors" | clp
`;

export class ArgsError extends Error {}

export function parseArgs(argv) {
  const result = {
    resume: false,
    sessionId: null,
    verbose: false,
    help: false,
    promptParts: [],
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case '--resume':
        result.resume = true;
        break;
      case '--session': {
        const value = argv[i + 1];
        if (!value) throw new ArgsError('--session requires a session id');
        result.sessionId = value;
        i += 1;
        break;
      }
      case '--verbose':
      case '-v':
        result.verbose = true;
        break;
      case '--help':
      case '-h':
        result.help = true;
        break;
      default:
        if (arg.startsWith('--')) {
          throw new ArgsError(`Unknown option: ${arg}`);
        }
        result.promptParts.push(arg);
    }
  }

  if (result.resume && result.sessionId) {
    throw new ArgsError('--resume and --session are mutually exclusive');
  }

  return {
    resume: result.resume,
    sessionId: result.sessionId,
    verbose: result.verbose,
    help: result.help,
    prompt: result.promptParts.length ? result.promptParts.join(' ') : null,
  };
}
