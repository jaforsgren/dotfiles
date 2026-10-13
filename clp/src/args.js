export const USAGE = `Usage: clp [options] ["<prompt>"]

Options:
  --resume             Resume the most recent session for this project
  --session <id>       Resume a specific session by id
  --interactive, -i    Stay open for a back-and-forth conversation
  --allow-all, -a      Skip permission prompts for this run (dangerous)
  --verbose, -v        Show detailed event output
  --help, -h           Show this help

Examples:
  clp "Fix the failing tests"
  clp --resume "Continue fixing the tests"
  clp --session abc123 "Continue working"
  echo "Fix the lint errors" | clp
  clp                       # interactive, prompts for input
  clp -i "Fix the tests"    # interactive, starting from a prompt
  clp -i --resume           # continue a prior session interactively
  clp --allow-all "Run the full test suite and fix failures"
`;

export class ArgsError extends Error {}

export function parseArgs(argv) {
  const result = {
    resume: false,
    sessionId: null,
    verbose: false,
    interactive: false,
    allowAll: false,
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
      case '--interactive':
      case '-i':
        result.interactive = true;
        break;
      case '--allow-all':
      case '-a':
        result.allowAll = true;
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
    interactive: result.interactive,
    allowAll: result.allowAll,
    help: result.help,
    prompt: result.promptParts.length ? result.promptParts.join(' ') : null,
  };
}
