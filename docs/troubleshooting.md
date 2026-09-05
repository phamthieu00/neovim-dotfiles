# Troubleshooting

Start with `make doctor`. `ERROR` means the Coding MVP contract is broken;
`WARNING` means an optional tool such as the faster `fd` finder or pnpm is
absent, or that Neovim cannot reach a system clipboard provider.

## A prerequisite is missing or too old

Install the exact category reported by doctor. On Ubuntu, `build-essential`,
`ripgrep`, and `fd-find` cover the compiler, Make, ripgrep, and optional finder.
Use a version manager or official distribution for Node.js >= 22.22.2 and the
official tree-sitter CLI >= 0.26.1. The installer will not replace shared
runtime toolchains.

## Neovim or PATH is wrong

`make install` can place Neovim 0.12.3 under `~/.local/opt` and link it from
`~/.local/bin`. Put that directory before older system binaries in `PATH`, then
open a new shell. The installer refuses to overwrite an unrelated binary or
symlink at that location.

## Plugin or parser synchronization fails

Check GitHub/network access, compiler and CLI versions, then run:

```vim
:Lazy sync
:checkhealth telescope
:checkhealth vim.treesitter
```

Telescope remains usable if native FZF fails to load because extension loading
is protected, but `make` and a compiler are still required by this repository's
installation contract. Parser failures usually include the parser name and
compiler output in `:messages` or the Lazy build log.

## LSP or completion does not attach

Open `:Mason` and confirm all six documented packages are installed. Then
inspect `:checkhealth vim.lsp` and `:LspInfo`. Servers normally need a
recognizable project root. Blink loads as the LSP capability provider;
completion behavior can be inspected with `:checkhealth blink.cmp`.

For TypeScript, confirm the file belongs to a `package.json`, `tsconfig.json`,
or supported workspace root and inspect which TypeScript version the server
selected. The upstream server uses a workspace TypeScript installation when
available and otherwise falls back to its bundled version.

For ESLint, keep the ESLint library and a flat or legacy ESLint configuration
in the project. In a monorepo, open Neovim from the workspace and inspect the
client root/working directory in `:LspInfo`. Use `:LspEslintFixAll` only when an
explicit whole-file fix is intended. JSON and JSONC use `jsonls` without
third-party schema catalogs; completion therefore reflects built-in or
project-provided schema information only.

## Formatting is unavailable

Run `:ConformInfo` in the affected buffer. Lua uses `stylua`; JavaScript,
TypeScript, React variants, JSON, JSONC, and YAML select the first available of
`prettierd` or `prettier`. Mason provides `stylua` and `prettierd`; a
project-local Prettier executable and configuration are preferred when found,
with `PATH` as fallback. Markdown is deliberately excluded. LSP formatting is
used only when no configured CLI formatter is available.

## Environment files and secrets

Neovim detects `.env`, `.env.example`, and environment-specific `.env.*` files
without repository-specific detection. Treat all of them as potentially
sensitive: keep real secrets out of Git, review `.gitignore`, and use redacted
example values. This configuration does not load, validate, transmit, or mask
environment values.

## File search misses or includes the wrong files

`<leader>ff` includes hidden files and excludes `.git`. It chooses `fd`, then
Ubuntu's `fdfind`, then `rg --files`. Confirm the selected executable is on
`PATH`; use `<leader>fg` for content search.

## Oil does not open or save changes

Confirm the `oil.nvim` checkout is installed with `:Lazy` and run `:Oil` from a
normal buffer. Oil represents a directory as an editable buffer: `<CR>` opens,
`-` moves to the parent, and `:w` applies pending filesystem edits. Use `g?` in
an Oil buffer for its built-in actions. The configuration does not add a tree
sidebar, icons, or shell-command wrappers.

## Pairs or surrounds behave unexpectedly

nvim-autopairs loads on the first Insert mode entry and keeps its default rules;
check `:messages` after startup and test in a disposable TypeScript buffer.
Blink handles completion acceptance separately, so do not add an nvim-cmp
`confirm_done` adapter. For surrounding changes, verify the operator and text
object separately (`ysiw"`, `ds)`, `cs"'`) and consult `:h nvim-surround.usage`.

## Which-key is missing a label

Run `:checkhealth which-key`, press `<Space>`, and inspect the original mapping's
`desc` with `:map`. The configuration labels only the `f`, `c`, `b`, and `h`
prefixes; it does not duplicate mappings just to populate the popup.

## Clipboard warning

Run `make doctor` to see which provider Neovim selected. Install the relevant
Wayland or X11 utility manually if needed, or continue using Vim's internal
registers and explicit `"+y`/`"+p` operations. This warning never blocks coding.

## The installer refuses or restores a path

The installer backs up any existing config and restores it if validation of a
new link fails. `make uninstall` refuses a directory or another repository's
symlink. Inspect paths and backups manually rather than deleting them.

## Resetting state

This project never deletes `~/.local/share/nvim`, `~/.local/state/nvim`, or
`~/.cache/nvim`. Back them up before removing anything manually. Prefer
`:Lazy clean`, Mason's UI, or targeted parser operations over broad deletion.
