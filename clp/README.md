# clp

A lightweight CLI wrapper around Claude Code, built on the official
[`@anthropic-ai/claude-agent-sdk`](https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk).

Runs a prompt straight through the Agent SDK — no interactive TUI — while
keeping the parts of Claude Code's interface that matter: compact live
visibility into what Claude is doing, interactive permission approval, session
continuity, and (optionally) a live back-and-forth conversation.

(Named `clp` because `cl` is already aliased elsewhere.)

## Install

```bash
cd clp
npm install
npm link        # makes the `clp` command available globally
```

`npm link` symlinks this package's `bin/clp.js` onto your `$PATH`. To remove
it later: `npm unlink -g clp`.

## Usage

```bash
clp "Fix the failing tests"
clp --resume "Continue fixing the tests"
clp --session <session-id> "Continue working"
clp --verbose "Refactor authentication"
echo "Fix the lint errors" | clp

# Interactive — a back-and-forth conversation in one process
clp                       # no prompt + a real terminal: prompts for input
clp -i "Tell me a joke"   # starts from a prompt, then keeps the conversation going
clp -i --resume           # continue a prior session interactively

# Skip permission prompts entirely for this run
clp --allow-all "Run the full test suite and fix failures"
```

| Flag | Meaning |
|---|---|
| `--resume` | Resume the most recent session recorded for the current directory |
| `--session <id>` | Resume a specific session by id |
| `--interactive`, `-i` | Stay open for a back-and-forth conversation instead of exiting after one reply |
| `--allow-all`, `-a` | Skip permission prompts for this run (see [Permissions](#permissions)) |
| `--verbose`, `-v` | Show tool inputs/outputs, session/model info, and cost/duration in full |
| `--help`, `-h` | Print usage |

By default `clp` is single-shot: one prompt in, one reply out, process exits
(so it's safe to script/pipe). Running it bare at an actual terminal with no
prompt is the one exception — there's nothing else useful to do with no
prompt and no stdin to read, so it opens the same interactive mode as `-i`.

## Interactive mode

```
$ clp -i "Tell me a knock-knock joke"
Session: 18b4274c-...
Claude: Knock knock.
> who's there?
Claude: Orange.
> orange who?
Claude: Orange you glad I didn't say banana?
> /exit
```

Each line waits for the previous turn to fully finish before prompting again
— so you can answer a clarifying question mid-conversation instead of having
to start a new `clp --resume "..."` invocation for every reply. Type `/exit`
or `/quit` (or Ctrl+D) to leave; Ctrl+C interrupts the turn in progress
without closing the session, or exits if nothing is running.

A prompt can be given as trailing arguments or piped via stdin. `clp` always
runs in the current working directory and loads that project's existing
`.claude/settings.json` / `CLAUDE.md` / permission rules, same as the
interactive CLI.

## Output

By default, output is compact: Claude's text, a one-line icon + summary per
tool call, and short tool results (errors are always shown; successful
results are summarized in `--verbose`). The run ends with `✔ Done` or
`✖ <reason>`, which also sets the process exit code (`0` on success, `1` on
error, `2` on bad usage, `130` on `Ctrl+C`).

## Permissions

Tool calls that your existing Claude Code permission settings don't already
resolve fall through to an interactive prompt:

```
🔒 Permission required
  Bash: npm install jsonwebtoken

  [y] Allow  [n] Deny  [a] Always allow
```

- `y` allows this one call.
- `n` denies it.
- `a` allows it and remembers the decision for next time, scoped to the
  current project directory and a narrow pattern — e.g. "always allow
  `Bash` commands starting with `npm`", not "always allow all Bash
  commands". Remembered approvals are stored in
  `~/.config/clp/store.json`.

The prompt is read from the controlling terminal (`/dev/tty`) rather than
stdin, so piping a prompt in (`echo "..." | clp`) doesn't interfere with
answering permission prompts. If no terminal is available at all (e.g.
running fully non-interactively), the request is denied by default — this
can be changed with the `nonInteractiveDefault` config option below, but
`clp` never grants blanket/unrestricted permissions automatically on its
own.

### `--allow-all`

`--allow-all` (`-a`) is an explicit, per-run opt-in that skips permission
prompts entirely — no `canUseTool` callback is even installed, so neither
`y`/`n`/`a` prompts nor the `nonInteractiveDefault` fallback apply. It prints
a one-line warning at startup so it's never silent:

```
⚠ --allow-all: permission prompts are disabled for this run.
```

Under the hood this sets `permissionMode: 'bypassPermissions'` and
`allowDangerouslySkipPermissions: true` for the Agent SDK — any explicit
`ask` rule in your Claude Code settings still prompts, since those are rules
you configured deliberately; this flag only removes the *default* "ask
before anything not already allowed" behavior. Use it for sandboxed/CI runs
or when you've already reviewed what the prompt will do — not as a default.

## Session management

Each run's session id is recorded per project directory in
`~/.config/clp/store.json`. `--resume` looks up the last session id for the
current directory; `--session <id>` resumes an explicit one. If no prior
session exists for the directory, `--resume` fails with a clear message
instead of silently starting a new session.

## Configuration

Optional preferences file at `~/.config/clp/config.json`:

```json
{
  "verbose": false,
  "truncateLength": 300,
  "nonInteractiveDefault": "deny"
}
```

| Key | Default | Meaning |
|---|---|---|
| `verbose` | `false` | Same as always passing `--verbose` |
| `truncateLength` | `300` | Max characters shown per line of tool input/output |
| `nonInteractiveDefault` | `"deny"` | `"allow"` or `"deny"` — what to do with a permission request when no terminal is available to prompt |

Everything else (allowed/disallowed tools, hooks, MCP servers, instructions)
is read from your existing Claude Code settings (`settingSources: ["user",
"project", "local"]`) rather than duplicated here.

## Development

```bash
npm test
```

Tests use Node's built-in test runner (`node --test`) — no test framework
dependency.

### Layout

| File | Purpose |
|---|---|
| `bin/clp.js` | Executable entry point |
| `src/cli.js` | Argument handling, SDK `query()` orchestration, Ctrl+C handling |
| `src/args.js` | CLI argument parsing |
| `src/format.js` | Renders SDK stream messages as compact/verbose text |
| `src/permissions.js` | Builds the `canUseTool` callback and the approve/deny/always-allow prompt |
| `src/tty-prompt.js` | Reads a single keypress from `/dev/tty` |
| `src/store.js` | Per-project session id + approval persistence (`~/.config/clp/store.json`) |
| `src/config.js` | User preferences (`~/.config/clp/config.json`) |
