# Keymaps

The leader is `<Space>` and the local leader is `\`. Plugin mappings live with
their specifications; LSP mappings exist only in buffers with an attached
server.

## Core

| Mapping | Mode | Action |
| --- | --- | --- |
| `<leader>w` | Normal | Save current file |
| `<leader>q` | Normal | Quit current window |
| `<Esc>` | Normal | Clear search highlighting |
| `<C-h/j/k/l>` | Normal | Focus the left/below/above/right window |
| `+` / `_` | Normal | Increase / decrease the current window width |
| `=` / `-` | Normal | Increase / decrease the current window height |
| `[b` / `]b` | Normal | Previous / next buffer |
| `<leader>bd` | Normal | Delete current buffer |

## Telescope

| Mapping | Action |
| --- | --- |
| `<leader>ff` | Find files, including hidden files but excluding `.git` |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find open buffers |
| `<leader>fr` | Find recently opened files |
| `<leader>fh` | Search help tags |
| `<leader>fd` | Search diagnostics |
| `<leader>fs` | Search symbols in the current document |
| `<leader>fS` | Dynamically search workspace symbols |

## Filesystem

| Mapping | Action |
| --- | --- |
| `<leader>fe` | Open Oil for the current working directory |

Telescope finds files and content; Oil edits nearby filesystem structure. Oil's
directory-buffer defaults provide navigation and file operations without extra
global mappings.

## LSP and diagnostics

| Mapping | Action |
| --- | --- |
| `gd` / `gD` | Go to definition / declaration |
| `gi` / `gr` | Go to implementation / find references |
| `gy` | Go to type definition |
| `K` | Show hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Request a code action |
| `<leader>ch` | Toggle inlay hints for the current buffer when supported |
| `<leader>e` | Show the diagnostic at the cursor |
| `]d` / `[d` | Jump to next / previous diagnostic |

Inlay hints start disabled. For explicit whole-file actions, use
`:LspTypescriptSourceAction` for TypeScript source actions such as organizing
imports and `:LspEslintFixAll` for ESLint fixes. Ordinary cursor/range fixes use
`<leader>ca`; no action runs on save.

## Surround

These are nvim-surround's default v4 operators rather than project-specific
leader mappings:

| Mapping | Action |
| --- | --- |
| `ys{motion}{char}` | Add a surround, for example `ysiw"` turns `user` into `"user"` |
| `ds{char}` | Delete a surround, for example `ds)` removes parentheses |
| `cs{target}{replacement}` | Change one, for example `cs"'` changes double to single quotes |

Use native text objects such as `iw`, `a"`, and `i(` with these operators.

## Which-key groups

Press `<Space>` and pause to discover the existing groups: `a` (AI agents), `f`
(Find / filesystem), `c` (Code), `b` (Buffers), and `h` (Git hunks). which-key
labels these prefixes; this document remains the canonical full reference.

## AI coding agents

| Mapping | Mode | Action |
| --- | --- | --- |
| `<leader>ac` | Normal | Toggle the Claude Code terminal |
| `<leader>cC` | Normal | Continue the latest Claude Code conversation in the right panel |
| `<leader>ax` | Normal | Focus or hide the Codex session |
| `<leader>ab` | Normal | Add the current buffer to Codex |
| `<leader>aa` | Visual | Add the selection to the Codex prompt |
| `<leader>as` | Visual | Send the selection to Codex |

These mappings only launch a CLI when used. Install and authenticate Claude
Code or Codex independently; no credentials are stored in this repository.
Both agents use resizable right-side splits. With the cursor in an agent
terminal, press `<C-\><C-n>` to enter terminal Normal mode, then use `+`/`_`
for width or drag the split edge because `mouse=a` is enabled.

Persistence automatically restores the current directory's last session when
you run plain `nvim` or `nvim .`. Use `<leader>qs` to retry the
current session manually, `<leader>qS` to choose another one, `<leader>ql` to
load the most recently saved session, and `<leader>qd` to stop saving for the
current Neovim process.

## Formatting and Git

| Mapping | Mode | Action |
| --- | --- | --- |
| `<leader>cf` | Normal or Visual | Format the buffer or selected range asynchronously |
| `]h` / `[h` | Normal | Jump to next / previous Git hunk |
| `<leader>hp` | Normal | Preview current Git hunk |
| `<leader>hb` | Normal | Show full blame for the current line once |

## Blink completion defaults

Blink's `default` preset is used unchanged. These insert-mode mappings are
effective while completion is active and fall back to normal Neovim behavior
when Blink cannot handle them:

| Mapping | Action |
| --- | --- |
| `<C-Space>` | Trigger completion; toggle documentation when appropriate |
| `<Up>` / `<C-p>` | Select previous item |
| `<Down>` / `<C-n>` | Select next item |
| `<C-y>` | Select and accept the completion |
| `<C-e>` | Cancel/dismiss completion |
| `<C-b>` / `<C-f>` | Scroll documentation up / down |
| `<Tab>` / `<S-Tab>` | Move forward / backward through snippet placeholders |

Documentation also opens automatically after 500 ms. `<C-k>` belongs to the
preset's signature-help behavior, but signature help is deliberately disabled
because Blink marks it experimental; it therefore falls back rather than
opening a signature window.
