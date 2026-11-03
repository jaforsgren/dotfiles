# dev cheatsheet

Run all lfant .NET apps (big-tusks-services + Sejfa.Internal) via [overmind](https://github.com/DarthSim/overmind), with combined logs in **lnav**. Defined in `.weapp_aliases`.

## Commands

| Command | Action |
|---|---|
| `dev up` / `dev u` | Start all / restart dead processes |
| `dev down` / `dev d` | Stop everything and close tmux |
| `dev ls` / `dev l` | Process states, health and ports |
| `dev status` / `dev s` | Raw overmind status (PID/state) |
| `dev logs` / `dev lg [process]` | View all or filtered logs in lnav |
| `dev attach` / `dev a <process>` | Attach to process (restarts if dead) |
| `dev restart` / `dev r <process>` | Restart one process |
| `dev clear` / `dev c` | Clear combined log |
| `dev help` / `dev h` | Show help |
| `dev` | List process names |

**`dev up` is safe to rerun:**
- No session → start everything.
- Overmind stopped → restart it, preserve logs.
- Running → restart only dead processes.
- Procfile changed → show diff; requires `dev down && dev up`.

## tmux & logs

Session: `ta overmind`

- `apps` — overmind (`--any-can-die`; crashes are isolated).
- `logs` — log collector + lnav.
- Detach from process: tmux prefix twice, then `d`.

**lnav shortcuts**

| Key / Command | Action |
|---|---|
| `e` / `E` | Next / previous error |
| `w` / `W` | Next / previous warning |
| `h` / `l` | Scroll horizontally |
| `G` | End of log / follow |
| `:set-min-log-level warning` | Hide info/debug |
| `:filter-expr :process = 'persona-grpc'` | Filter process |
| `0`–`7` | Service filter (see below) |

**lnav service filters** (`overmind/lnav/configs/overmind/keymap.json`)

Each key shows only that service's processes (`:filter-expr :process LIKE '<service>-%'`). These replace lnav's default `1`–`7` time jumps.

| Key | Shows |
|---|---|
| `0` | All services (clear filter) |
| `1` | claimdocs |
| `2` | iibproxy |
| `3` | insurify |
| `4` | payments |
| `5` | persona |
| `6` | sejfa |
| `7` | whisper |

Adding a service to `Procfile.lfant`? Add a key for it in `keymap.json` too.

Log format: `<timestamp> <process> | <line>`


