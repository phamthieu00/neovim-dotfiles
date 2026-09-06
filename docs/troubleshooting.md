# Troubleshooting

Start with `make doctor`. `ERROR` means the Coding MVP contract is broken;
`WARNING` means an optional tool such as the faster `fd` finder or pnpm is
absent, or that Neovim cannot reach a system clipboard provider.

## A prerequisite is missing or too old

Install the exact category reported by doctor. On Ubuntu, `build-essential`,
`ripgrep`, and `fd-find` cover the compiler, Make, ripgrep, and optional finder.
Use NVM or an official distribution for Node.js >= 22.22.2 with npm, then
re-run `make install`; Ubuntu provisions a verified user-local tree-sitter
archive when the existing version is missing or too old. The installer will
not replace a sufficient shared runtime or an unrelated local binary/symlink.

## Neovim or PATH is wrong

`make install` can place Neovim 0.12.3 under `~/.local/opt` and link it from
`~/.local/bin`. Put that directory before older system binaries in `PATH`, then
open a new shell. The installer refuses to overwrite an unrelated binary or
symlink at that location.

If install stops at `Neovim archive checksum verification failed` on macOS,
update the repository and retry. macOS's `/sbin/sha256sum` uses the BSD command
interface, so the installer falls back to `/usr/bin/shasum` instead of passing
it GNU-only `--check --status` options.

Neovim uses `~/.config/nvim` and `~/.local/share/nvim` by default on macOS as
well as Linux. If an older install created links under `~/Library/Application
Support`, those links are not read by the current Neovim binary; they are left
untouched by this installer.

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

`ts_ls` is the nvim-lspconfig server identifier, not a Mason package name.
Install or retry the corresponding Mason package with
`:MasonInstall typescript-language-server`. If Mason reports `npm` as `ENOENT`
or an LSP exits with code 127, install Node.js >= 22.22.2 with npm and ensure
both `node` and `npm` are visible in the same shell that starts Neovim.

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
sidebar or shell-command wrappers.

## Pairs or surrounds behave unexpectedly

nvim-autopairs loads on the first Insert mode entry and keeps its default rules;
check `:messages` after startup and test in a disposable TypeScript buffer.
Blink handles completion acceptance separately, so do not add an nvim-cmp
`confirm_done` adapter. For surrounding changes, verify the operator and text
object separately (`ysiw"`, `ds)`, `cs"'`) and consult `:h nvim-surround.usage`.

## Which-key is missing a label

Run `:checkhealth which-key`, press `<Space>`, and inspect the original mapping's
`desc` with `:map`. The configuration labels only the `a`, `f`, `c`, `b`, and
`h` prefixes; it does not duplicate mappings just to populate the popup.

## Icons or command line are missing

Oil and bufferline icons come from `nvim-web-devicons`; use a Nerd
Font and inspect `:Lazy`/`:messages` if symbols render as boxes. The
`:` command line is centered by Noice's `cmdline_popup` view.
Run `:checkhealth noice` and inspect `:Lazy` if it appears at the native bottom
position. `:Noice` opens its message history; removing Noice intentionally
restores Neovim's native command-line.

## Clipboard warning

Run `make doctor` to see which provider Neovim selected. Install the relevant
Wayland or X11 utility manually if needed, or continue using Vim's internal
registers and explicit `"+y`/`"+p` operations. This warning never blocks coding.

## AI CLI integrations

The Claude Code and Codex plugins are lazy, so a missing CLI does not prevent
Neovim from starting. `make doctor` reports missing `claude` or `codex` as a
warning. Install and authenticate the CLI in the shell environment that starts
Neovim, then verify with:

```bash
command -v claude && claude --version
command -v codex && codex --version
```

Inside Neovim, use `:ClaudeCode` or `:ClaudeCodeContinue` for Claude and
`:Codex`, `:CodexStatus`, or `:CodexHealth` for Codex. If a terminal does not
open, inspect `:messages` and confirm the command is available from Neovim's
`$PATH`; do not add credentials or shell auto-start hooks to this repository.
The Codex integration is community maintained, so CLI protocol changes may
require a plugin update. Review the CLI's own auth/configuration files rather
than committing them here.

## The installer refuses or restores a path

The installer backs up any existing config and restores it if validation of a
new link fails. `make uninstall` refuses a directory or another repository's
symlink. Inspect paths and backups manually rather than deleting them.

## Resetting state

`make uninstall` removes only the plugin/Mason/site paths and state/cache paths
recorded by this repository's ownership marker. It preserves unrelated files
under the Neovim roots. If the marker is absent, it leaves all plugin/data
directories untouched; prefer `:Lazy clean`, Mason's UI, or targeted parser
operations for manual cleanup.

## Restoring work automatically

Enter the project directory and run plain `nvim` or `nvim .`. Persistence
restores that directory's saved Neovim layout automatically. Opening
`nvim some-file.ts` intentionally skips restore so the explicit file wins.
