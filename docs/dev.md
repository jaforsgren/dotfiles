# dev cheatsheet

Runs every lfant .NET app (big-tusks-services + Sejfa.Internal) under
[overmind](https://github.com/DarthSim/overmind), with combined logs in lnav.
Defined as the `dev` function in `.weapp_aliases`.

## Commands

- `dev up` - start all servers in the `overmind` tmux session (attach with `ta overmind`).
  Safe to rerun:
  - no session: creates it and starts everything
  - session exists, overmind not running: starts overmind again in a fresh `apps` window
    (the `logs` window and lnav are kept, missing `logs` window is recreated)
  - overmind running: restarts only processes that are `dead`, running ones are untouched.
    overmind never re-reads the Procfile, so if it changed since overmind started, `dev up`
    prints the changed lines, restarts nothing and tells you to run `dev down && dev up`
- `dev down` - quit overmind gracefully (force kill after 30s) and close the tmux session
- `dev ls` - every process with overmind state, health check result and health port;
  shows `not started` for processes overmind isn't running
- `dev status` - raw `overmind status` (PID + state)
- `dev logs` - lnav on the combined log
- `dev logs <process>` - lnav filtered to one process
- `dev attach <process>` - interactive tmux connection to one process
  (inside tmux: prefix twice, then `d` to detach). A dead process only has a read-only
  "Pane is dead" pane, so attach first prints its last 20 log lines (why it died),
  restarts it, then connects
- `dev clear` - empty the log file
- `dev help` - this page

Process names accept partial matches (`appapi` -> `sejfa-appapi`); ambiguous
ones (`api`) are rejected with the candidates listed. Plain `dev` prints all names.

## Processes

| Process | Project |
| --- | --- |
| sejfa-appapi / sejfa-worker | Sejfa.Internal AppApi / Worker |
| claimdocs-grpc / claimdocs-worker | claim-documentation GrpcServer / Worker |
| iibproxy-grpc | iib-proxy GrpcServer |
| insurify-grpc / insurify-worker | Insurify GrpcServer / Worker |
| payments-grpc / payments-webapi / payments-worker | payments GrpcServer / WebApi / Worker |
| persona-grpc / persona-worker / persona-webhook | persona GrpcServer / Worker / RoaringWebhookApi |
| whisper-grpc / whisper-worker | whisper GrpcServer / Worker |

## Procfile format

Each line uses the `cd-*` aliases and the repo's make target, e.g.
`sejfa-worker: cd-sejfa && make run-worker`. overmind runs every process through
`overmind/procshell.sh` (`--shell`), which loads `.bash_aliases` first so the
aliases work in its non-interactive shell. Every repo (incl. iib-proxy and
whisper) has `run-*` make targets.

## tmux session `overmind`

- window 1 `apps` - `overmind start` (`--any-can-die`, so one crash doesn't stop the rest)
- window 2 `logs` - `overmind echo | stamp-log.pl >> <log file>` loop (small pane) + lnav on the log

## Log format and lnav

Every line in the combined log is `<timestamp> <process> | <line>`: `overmind/stamp-log.pl`
adds the timestamp and strips color/cursor escape codes, and `procshell.sh` switches .NET
console logging to single line (`info: Category[0] message`). lnav loads the
`overmind_log` format from `overmind/lnav` (`-I`), so it opens in LOG view with levels
(`fail` = error, `crit` = critical) and a `process` field.

Useful lnav keys:

- `e` / `E` - next / previous error, `w` / `W` - next / previous warning
- `h` / `l` (or arrows) - scroll left / right; `0` back to the start of the line
- `G` - jump to the end and keep following new lines
- `:filter-expr :process = 'persona-grpc'` - only one process (what `dev logs <process>` does)
- `:set-min-log-level warning` - hide info/debug

## Health checks

`dev ls` finds each app's project directory by replaying its Procfile line with
`make`/`dotnet` stubbed out (the `cd-*` alias + `make -n`'s `--project`), then reads
its `Kestrel.Endpoints.Health.Url` port from `appsettings.Development.json` and calls `/healthz/ready` with
`Host: localhost:8081` (DevelopHub.Foundation maps health checks with
`RequireHost("*:8081")`). Results: `healthy` (200), `unhealthy` (503),
`down` (no answer), `http <code>` (anything else).

## Config locations

| What | Where |
| --- | --- |
| Procfile (process list) | `~/DEV/dotfiles/overmind/Procfile.lfant` |
| Shared paths + overmind status/alias helpers | `~/DEV/dotfiles/overmind/lfant.sh` |
| Process shell (loads aliases, plain build output, single-line .NET logs) | `~/DEV/dotfiles/overmind/procshell.sh` |
| Log stamper (timestamps, strips escape codes) | `~/DEV/dotfiles/overmind/stamp-log.pl` |
| lnav format | `~/DEV/dotfiles/overmind/lnav/formats/overmind/overmind_log.json` |
| Process -> project dir resolver (used by `dev ls`) | `~/DEV/dotfiles/overmind/process-dir.sh` |
| tmux session script | `~/DEV/dotfiles/tmux-sessions/start-overmind.sh` |
| `dev` function | `~/DEV/dotfiles/.weapp_aliases` |
| Overmind socket | `/tmp/overmind-lfant.sock` |
| Combined log | `/tmp/overmind-lfant.log` |
| Procfile snapshot overmind started with | `/tmp/overmind-lfant.Procfile` |
| App root (overmind working dir) | `~/DEV/lfant` |

## Raw overmind

All commands need `-s /tmp/overmind-lfant.sock`:

- `overmind restart <process>` - restart one process
- `overmind stop <process>` - stop one process
- `overmind kill` - kill everything immediately
