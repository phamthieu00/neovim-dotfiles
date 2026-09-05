# Daily Editing

This configuration keeps everyday editing close to Neovim's native model. Use
the smallest tool that matches the task: motions and text objects for local
changes, Telescope for finding, and Oil for filesystem operations.

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

Buffers are ordinary open files, not permanent tabs. Use `[b` and `]b` to move
between buffers, `<leader>fb` to find one with Telescope, and `<leader>bd` to
delete the current buffer using native `:bdelete`.

## Windows

Use `<C-h>`, `<C-j>`, `<C-k>`, and `<C-l>` to focus the neighboring window.
Native commands remain available for layout changes: `:split`, `:vsplit`,
`:close`, and `:only`. No window manager or resize plugin is included.

## Filesystem and search

- `<leader>fe` opens Oil in the current working directory. Treat the directory
  as an editable buffer: press `<CR>` to open, `-` to go up, edit names or
  entries, then `:w` to apply create/rename/move/delete operations.
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
filesystem), `c` (Code), `b` (Buffers), and `h` (Git hunks) groups. Existing
mapping descriptions are the source of truth, so [docs/keymaps.md](keymaps.md)
remains the complete reference.
