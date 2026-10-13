# clp cheatsheet

A small CLI wrapper around Claude Code.

One prompt in, one reply out.

## Run

- `clp "Fix the tests"` - run a single prompt

- `echo "Fix lint" | clp` - pipe a prompt in

- `clp` - no prompt opens interactive mode

## Flags

- `-i`, `--interactive` - keep the conversation going

- `--resume` - continue the last session in this directory

- `--session <id>` - continue a specific session

- `-a`, `--allow-all` - skip permission prompts (dangerous)

- `-v`, `--verbose` - show tool input, output and cost

- `-h`, `--help` - print usage

`--resume` and `--session` cannot be combined.

## Interactive mode

- `clp -i "Tell me a joke"` - start from a prompt

- `clp -i --resume` - pick up where you left off

- `/exit` or `/quit` or `ctrl+d` - leave

- `ctrl+c` - stop the current turn

## cln

Write the prompt in nvim first.

- `cln` - open a scratch buffer, `:wq` sends it to clp

- `:q!` - quit without sending

## Config

Optional file: `~/.config/clp/config.json`

- `verbose` - always verbose, default `false`

- `truncateLength` - max line length, default `300`

- `nonInteractiveDefault` - `allow` or `deny` without a terminal, default `deny`
