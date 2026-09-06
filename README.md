# Neovim Configuration

A small, explicit Neovim 0.12+ development environment maintained as a
long-lived software project.

## Requirements

- Ubuntu 22.04/24.04 or macOS on x86_64/arm64 for automatic provisioning
- Git, cURL, tar, gzip, unzip, and SHA-256 utilities
- Neovim 0.12+ (the automated path pins 0.12.3)
- ripgrep, Make, and a C compiler
- Node.js >= 22.22.2 and npm
- tree-sitter CLI >= 0.26.1
- `fd` or Ubuntu's `fdfind` is optional; file search falls back to ripgrep
- network access while installing or updating

On macOS, `make install` can bootstrap Homebrew and the required Coding MVP
tools. On Ubuntu, it provisions only transport packages and Neovim, reporting
exact guidance for major runtimes and build tools instead of changing them.
See [installation](docs/installation.md) for details.

## Installation

```bash
git clone <repository-url> ~/projects/neovim-config
cd ~/projects/neovim-config
make install
```

The installer checks prerequisites before touching `~/.config/nvim`, backs up
any existing configuration, and symlinks this repository into place. It then
synchronizes plugins and parsers and installs the required Mason tools.

## Coding workflow

- Find files, text, buffers, history, help, and diagnostics with Telescope.
- Browse and edit nearby directories as buffers with Oil; use `<leader>fe` for
  filesystem operations.
- Edit Lua, JavaScript, TypeScript, JSON, and JSONC with Treesitter highlighting,
  LSP diagnostics, navigation, and Blink completion where supported.
- Use native motions and text objects, nvim-surround's `ys`/`ds`/`cs` operators,
  and nvim-autopairs for routine editing.
- Press `<Space>` and pause to discover existing leader mappings with which-key.
- Use TypeScript and ESLint source actions explicitly; the editor respects
  project-local TypeScript, ESLint, Prettier, and configuration files.
- Format explicitly with `<leader>cf`; format-on-save is intentionally absent.
- Inspect Git hunks and one-shot blame without adding a second Git UI.

The leader is `<Space>` and the local leader is `\`. The complete mapping
reference, including Blink's defaults, is in [docs/keymaps.md](docs/keymaps.md).

## Structure

```text
init.lua             Seven-line startup orchestrator
lua/config/          Plugin-independent editor behavior and lazy bootstrap
lua/plugins/         Focused plugin specifications, one owner per feature
after/lsp/           Focused overrides for lua_ls and eslint
scripts/             Safe installation and maintenance workflows
tests/               Network-free runtime smoke tests and a lightweight TS fixture
docs/                Architecture and operational rationale
.github/workflows/   Reproducible Ubuntu validation
```

`after/ftplugin/` remains absent until a real filetype-local setting is needed.
See [architecture](docs/architecture.md) and [plugins](docs/plugins.md).

## Language support

Mason provisions `lua-language-server`, `typescript-language-server`,
`eslint-lsp`, `json-lsp`, `stylua`, and `prettierd`. The enabled Neovim server
identifiers are `lua_ls`, `ts_ls`, `eslint`, and `jsonls`. TypeScript uses
upstream project discovery, ESLint diagnostics and fixes remain separate from
Conform formatting, and JSON completion intentionally has no SchemaStore
dependency. YAML is formatted but has no LSP; Markdown receives no new language
tooling. See [languages](docs/languages.md) for project expectations, commands,
and `.env` handling.

Go, Python, Docker, Kubernetes, Terraform, test runners, and debuggers remain
future milestones. Claude Code and Codex CLI integrations are available as
optional AI front ends; their CLIs and authentication remain user-managed.

## Daily coding UX

Use Telescope when you know part of a file name or its contents (`<leader>ff`,
`<leader>fg`). Use Oil when you need to inspect or change nearby filesystem
structure—create, rename, move, or delete entries in an editable directory
buffer. `<leader>fb`, `[b`, `]b`, and `<leader>bd` keep buffer navigation simple.
The bufferline keeps all open buffers visible at the top.
Persistence restores the current project session automatically; native
quickfix/location lists and undo history remain available without extra UI
plugins.

For editing, learn native motions and text objects first. Catppuccin Mocha
provides the active color scheme. nvim-surround adds
`ys`, `ds`, and `cs` for changing delimiters, while nvim-autopairs completes
typed pairs without changing Blink's completion behavior. which-key exposes the
existing `a`, `f`, `c`, `b`, and `h` leader groups. Oil shows file icons, and Noice
renders `:` as a centered command-line popup. Persistence restores the current
project session automatically when plain `nvim` or `nvim .` is launched. [docs/editing.md](docs/editing.md)
is the practical walkthrough.

For AI-assisted work, `<leader>ac` opens Claude Code in a right-side panel and
`<leader>cC` continues its latest conversation there. `<leader>ax` focuses Codex; `<leader>ab` adds the
current buffer and visual `<leader>aa`/`<leader>as` add or send a selection.
These mappings launch the existing `claude` or `codex` CLI only when invoked.
Both agents open in resizable right-side panels. Install and authenticate those
tools separately, and review agent changes with Git signs and native diffs.

## Commands

```bash
make install    # link, synchronize, provision, and validate
make doctor     # check dependencies, tools, packages, parsers, and health
make test       # run two network-free isolated starts and runtime assertions
make update     # update from a clean worktree and show lockfile changes
make uninstall  # remove the link and only marked project-owned plugin data
```

Inside Neovim, use `:Lazy`, `:Mason`, `:ConformInfo`, `:Noice`, `:ClaudeCode`,
`:Codex`, `:CodexHealth`, and focused
`:checkhealth vim.lsp`, `:checkhealth telescope`,
`:checkhealth vim.treesitter`, `:checkhealth mason`, or `:checkhealth which-key`
diagnostics.

## Development

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) before making
changes. Review `lazy-lock.json` independently whenever plugin revisions move.
Common failures and recovery steps are in
[docs/troubleshooting.md](docs/troubleshooting.md).
