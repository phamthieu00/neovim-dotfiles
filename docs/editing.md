# Daily Editing

This configuration keeps everyday editing close to Neovim's native model. Use
the smallest tool that matches the task: motions and text objects for local
changes, Telescope for finding, and Oil for filesystem operations.

## Statusline

The bottom statusline uses Neovim's built-in statusline and shows the current
mode, Git branch when available, file path and modified state,
filetype, LSP diagnostic counts, and cursor position. It does not add a
statusline plugin or change the existing buffer/window model.

## Terminal

Press `<C-\>` in Normal mode to toggle the main terminal. The terminal opens in
Insert mode, and the same key can toggle it while the terminal is focused.
`<leader>t1`, `<leader>t2`, and `<leader>t3` select numbered terminals;
`<leader>ts` opens the terminal selector.

## Native motions

Start with these high-frequency motions:

| Keys | Meaning |
| --- | --- |
| `h` `j` `k` `l` | Move left, down, up, and right |
| `w` `b` `e` | Move by word forward, backward, and to its end |
| `0` `$` | Start and end of the line |
| `gg` `G` | Start and end of the buffer |
| `<C-u>` `<C-d>` | Scroll half a screen up or down |
| `f{char}` `t{char}` | Move to or before the next character |
| `%` | Jump between matching delimiters |

### Operators and objects

Neovim composes an operator with a motion or text object:

```text
d + iw  -> diw   delete inner word
c + iw  -> ciw   change inner word
y + iw  -> yiw   yank inner word
d + $   -> d$    delete to the end of the line
```

Useful native text objects include `iw`/`aw` for words, `i"`/`a"` and
`i'`/`a'` for quotes, and `i(`/`a(` and `i{`/`a{` for delimited regions.

## Surround

nvim-surround adds three standard operators:

- `ys{motion}{char}` adds a surround. With the cursor on `user`, `ysiw"`
  produces `"user"`.
- `ds{char}` deletes one. On `(value)`, `ds)` leaves `value`.
- `cs{target}{replacement}` changes one. `cs"'` changes `"user"` to
  `'user'`.

The plugin's default v4 mappings also support visual selections and function or
tag surrounds. Use native text objects first; no Treesitter textobject plugin
is required.

## Autopairs

In Insert mode, nvim-autopairs closes `()`, `[]`, `{}`, quotes, and backticks and
skips an existing closing character when appropriate. It uses default rules, so
decorators, strings, template literals, and TSX are not given special editor
policy. Blink remains responsible for completion acceptance and its own
function-bracket behavior.

## Comments

Neovim 0.12 provides native commenting mappings. `gcc` toggles the current line
and visual `gc` toggles the selected lines. The buffer's `commentstring` controls
the comment syntax; no comment plugin is installed.

## Buffers

Buffers are ordinary open files, not permanent tabs. The bufferline at the top
keeps open buffers visible; use `[b` and `]b` to move between them,
`<leader>fb` to find one with Telescope, and `<leader>bd` to delete the current
buffer using native `:bdelete`.

Opening two buffers does not automatically create two windows. To start with
two files side by side from a shell, use `nvim -O file1 file2`; inside Neovim,
use `:vsplit file2`. Use `nvim -o`/`:split` for horizontal windows, or
`nvim -p file1 file2`/`:tabedit file2` for separate tab pages. The `<C-h/j/k/l>`
mappings move between windows; `[b` and `]b` switch buffers in the current
window.

## Windows

Use `<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>` to focus the neighboring window.
Native commands remain available for layout changes: `:split`, `:vsplit`,
`:close`, and `:only`. In Normal mode, `+`/`_` resize width and `=`/`-`
resize height. Agent panels are ordinary resizable right-side splits; in a
terminal buffer first press `<C-\><C-n>`, or drag the split edge with the mouse.
No window manager or resize plugin is included.

## Filesystem and search

- `<leader>fe` opens Oil in the current working directory. Treat the directory
  as an editable buffer: press `<CR>` to open, `-` to go up, edit names or
  entries, then `:w` to apply create/rename/move/delete operations. In Oil,
  `<C-s>` opens the selected file in a vertical split, `<C-h>` in a horizontal
  split, and `<C-t>` in a new tab. File icons are provided by
  `nvim-web-devicons` when
  the terminal font supports them.
- `<leader>ff` uses Telescope to fuzzy-find a file when you know part of its
  name.
- `<leader>fg` searches repository contents. `/`, `n`, and `N` remain the right
  tools for searching within the current buffer.
- `<leader>fh` searches Neovim help tags; useful native topics include
  `:help motion`, `:help text-objects`, `:help registers`, `:help buffers`, and
  `:help windows`.

## Registers and clipboard

Yanks and deletes preserve Vim registers. Use `"+y` and `"+p` when you
specifically want the system clipboard. `make doctor` reports a missing system
clipboard provider as a warning only; coding and internal registers continue to
work without one.

## Undo and redo

Persistent undo is enabled. Use `u` to undo and `<C-r>` to redo. `:undolist`
shows the files covered by the native undo history; no undo-tree plugin is
needed.

## Discoverability

Press `<Space>` and pause to see which-key's labels for the `f` (Find /
filesystem), `c` (Code), `b` (Buffers), `g` (Git), and `h` (Git hunks) groups. Existing
mapping descriptions are the source of truth, so [docs/keymaps.md](keymaps.md)
remains the complete reference.

The `:` command line is rendered as a centered popup by Noice. Use `:Noice` to
open message history and `:checkhealth noice` when the popup is unavailable.

Bufferline keeps open buffers visible without replacing native windows. Persistence
provides `<leader>qs` to load the current session, `<leader>qS` to select one,
`<leader>ql` to load the last session, and `<leader>qd` to stop saving. Native
quickfix, location-list, and undo commands remain available without extra UI
wrappers.
