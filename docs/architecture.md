# Architecture

The configuration has one clear owner for each kind of behavior. This keeps
startup inspectable and allows a language or plugin to be changed without
turning the repository into a framework.

## Startup flow

```text
init.lua
  -> config/options.lua
  -> config/keymaps.lua
  -> config/autocmds.lua
  -> config/lazy.lua
       -> lazy.nvim
       -> lua/plugins/*.lua
            -> after/lsp/*.lua (merged by Neovim for enabled servers)
```

The seven-line `init.lua` sets leaders before any mappings are created, then
loads core modules in a predictable order. `config/lazy.lua` owns bootstrap and
imports focused specifications; it does not own plugin behavior. `config/node.lua`
discovers an existing PATH/NVM Node binary without modifying shell files.

## Ownership

| Location | Responsibility |
| --- | --- |
| `lua/config/` | Behavior that works without third-party plugins, plus lazy bootstrap |
| `lua/plugins/telescope.lua` | Interactive finding and its finder dependencies |
| `lua/plugins/treesitter.lua` | Parser lifecycle and scoped highlighting |
| `lua/plugins/lsp.lua` | Shared LSP, diagnostics, Mason, capabilities, and attach mappings |
| `lua/plugins/completion.lua` | Blink completion behavior |
| `lua/plugins/format.lua` | Explicit formatter selection and invocation |
| `lua/plugins/git.lua` | Buffer-local Git signs and hunk mappings |
| `lua/plugins/oil.lua` | Editable filesystem navigation and operations |
| `lua/plugins/autopairs.lua` | Default typed-pair insertion |
| `lua/plugins/surround.lua` | Add, change, and delete delimiter surrounds |
| `lua/plugins/which-key.lua` | Discovery labels for the existing keymap groups |
| `lua/plugins/theme.lua` | Catppuccin color scheme and its startup activation |
| `lua/plugins/noice.lua` | Centered command-line and message UI |
| `lua/plugins/bufferline.lua` | Visible buffer tabs and LSP diagnostic counts |
| `lua/plugins/persistence.lua` | Explicit session persistence commands |
| `lua/plugins/terminal.lua` | Toggleterm terminal sessions and mappings |
| `lua/plugins/claude-code.lua` | Claude Code CLI terminal and editor bridge |
| `lua/plugins/codex.lua` | OpenAI Codex CLI terminal/app-server bridge |
| `after/lsp/<server>.lua` | Settings that differ from a server's upstream defaults |
| `after/ftplugin/<filetype>.lua` | Future buffer-local, filetype-specific editor settings |
| `scripts/`, `tests/`, `docs/` | Operations, executable contracts, and design rationale |

`after/lsp/lua_ls.lua` exists because Lua needs Neovim runtime knowledge.
`after/lsp/eslint.lua` disables only server formatting so Conform remains the
single formatting interface. There is no `ts_ls.lua` or `jsonls.lua` because
their upstream defaults are sufficient, and no empty `after/ftplugin/` because
empty scaffolding falsely suggests supported behavior.

## Loading decisions

Treesitter is non-lazy because parsers and `FileType` highlighting must be ready
deterministically. Oil is also non-lazy: its directory buffers replace the
current editing view, and lazy-loading that entry point is unreliable. Telescope
loads by command or mapping. Conform loads from its mapping, Blink from insert
mode or as an LSP dependency, and Gitsigns/LSP load for file buffers. Autopairs
loads on `InsertEnter`; surround and which-key defer to `VeryLazy`. Persistence
loads eagerly so it can restore a plain launch. LSP
configuration runs only after nvim-lspconfig is on the runtime path; Mason then
installs and automatically enables exactly `lua_ls`, `ts_ls`, `eslint`, and
`jsonls`.

Bufferline loads at `VeryLazy` and only renders a tab-like view of the existing
buffers; it does not change native split or tab-page semantics. The Catppuccin
theme loads early with high priority so every later plugin sees a
consistent palette. Its spec owns only the color scheme; it does not add UI
mappings. `nvim-web-devicons` owns file glyphs for Oil and bufferline, while
Noice owns the command-line presentation and uses `nui.nvim` for floating
rendering.

Claude Code and Codex are explicit exceptions to the conservative plugin policy
because the user requested both AI CLI workflows. Each owns only its own CLI
bridge and lazy-loads on commands or mappings. They do not duplicate LSP,
completion, formatting, diagnostics, or file browsing. CLI binaries and
authentication remain external to this repository, and no AI process starts at
Neovim startup.

Persistence starts on `VimEnter`/file buffers, saves on exit, and restores the
current directory's session automatically for plain `nvim` and directory
launches such as `nvim .`. Explicit file arguments are never hijacked. The
`<leader>qs`/`<leader>ql` mappings remain useful when a different session is
wanted.

Treesitter's rewritten `main` API owns parser installation. A scoped `FileType`
autocmd starts highlighting for supported types; JSONC reuses the maintained
JSON parser alias. Indentation, folding, and extension plugins are intentionally
excluded.

Language servers provide navigation, completion data, diagnostics, and explicit
code actions. Conform alone selects CLI formatters. Oil owns filesystem
operations; Telescope remains the fuzzy search owner. There are no save hooks for
formatting, ESLint fixes, or import organization, which makes file mutation a
visible user action and leaves project policy in the project.

## Reproducibility and extension

`lazy-lock.json` records plugin revisions and belongs in version control. Mason
packages and Treesitter parsers live under Neovim's data directory, not this
repository; installer, doctor, and smoke tests reconcile and validate them.
The installer records its repository identity in a small ownership marker so
uninstall can remove its lazy/Mason/site payload without guessing about shared
Neovim data.

For later language support, add a focused server override only when necessary,
extend the explicit Mason/parser/formatter lists, and add a real ftplugin only
for buffer-local settings. Project-local TypeScript, ESLint, and Prettier
dependencies remain application-owned; Neovim does not create package-manager
files or install a project dependency tree. Go, Python, Docker, Kubernetes, and
Terraform should remain independent changes rather than enlarging the shared
LSP module with language-specific policy. Do not add another file tree, motion,
cosmetic, or statusline plugin unless a concrete workflow gap is demonstrated
or the user explicitly requests the UI behavior. Debugger, dashboard,
schema-store, and legacy lsp-zero modules remain unimported because they add
unrelated services or outdated API assumptions without being required here.
The requested Claude Code and Codex bridges are kept as separate, removable
integrations.
