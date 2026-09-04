# tmux cheatsheet

Prefix: `ctrl+a` (not default ctrl+b)

## Sessions
- `tmux new -s name` - new session
- `tmux a -t name` - attach
- `tmux ls` - list sessions
- `ctrl+a d` - detach
- `ctrl+a $` - rename session
- `ctrl+a s` - list/switch sessions

## Windows
- `ctrl+a c` - new window
- `ctrl+a ,` - rename window
- `ctrl+a n` / `ctrl+a p` - next / prev window
- `ctrl+a 0-9` - go to window N
- `ctrl+a w` - list windows
- `ctrl+a &` - kill window

## Panes
- `ctrl+a %` - split vertical
- `ctrl+a "` - split horizontal
- `ctrl+a o` - cycle panes
- `ctrl+a arrow` - move to pane
- `ctrl+a x` - kill pane
- `ctrl+a z` - zoom/unzoom pane
- `ctrl+a {` / `ctrl+a }` - swap pane left/right
- `ctrl+a ctrl+arrow` - resize pane

## Copy mode
- `ctrl+a [` - enter copy mode
- `q` - quit copy mode
- `space` - start selection (vi mode)
- `enter` - copy selection
- `ctrl+a ]` - paste

## Misc
- `ctrl+a r` - reload config (if bound)
- `ctrl+a ?` - list all keybindings
- `ctrl+a :` - command prompt
