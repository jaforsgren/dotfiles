# nvim cheatsheet

Config: `~/.config/nvim` (LazyVim based). Leader: `space`

## Basic motions
- `gc` - comment
- `*` - search word under cursor
- `o` - insert on new row
- `x` - delete char
- `gd` - go to definition
- `ctrl+u` / `ctrl+d` - up / down half page
- `w` / `b` / `e` - word forward / back / end
- `0` / `$` - start / end of line
- `5gg` / `5G` - go to line 5
- `za` - toggle fold
- `zM` / `zR` - close / open all folds

## Selection & edit
- `vaw`, `va(` - select word / inside paren
- `dd`, `D`, `d0` - delete line / to end / to start
- `da(`, `dib`, `dii` - delete inside paren / block / indent
- `ya(`, `yiw` - yank inside paren / word
- `ciw` - change word under cursor
- `:%s/old/new/g` - replace all (add `c` to confirm)

## Custom keymaps
- `<leader>hh` - show cheatcheat.md in split
- `<leader>hk` - reload keymaps.lua
- `<leader>hr` - reload config
- `<leader>hm` - show messages
- `<leader>e` - toggle Neo-tree (float)
- `ctrl+e` - Neo-tree float, reveal current file
- `<leader>fe` - Neo-tree reveal file
- `<leader>bb` / `ctrl+b` - Telescope buffers
- `<leader><leader>` - find files (excludes node_modules/.git/bin/etc)
- `<leader>sg` - live grep (same exclusions)
- `ctrl+s` - Telescope document symbols
- `ctrl+r` - Telescope lsp references
- `<leader>T` group - Tb buffers, TT telescope, Ts doc symbols, TS workspace symbols, Tr references
- `gi` - go to implementation
- `gp` / `gP` - next / prev error (errors only)
- `ctrl+w` - search & replace word under cursor
- `p` (visual) - paste without clobbering register
- `yp` / `yP` - yank relative / absolute file path
- `<esc>` - quit window (acts like :q)
- `K` - hover docs
- `<leader>rn` - LSP rename
- `<leader>ca` - code action
- `<leader>cA` - auto-fix all single-action errors in buffer
- `J` / `K` (normal) - scroll down/up half page, centered
