# Neovim Configuration

A small, explicit Neovim 0.12+ development environment maintained as a
long-lived software project. Milestone 3A extends the Coding MVP for
TypeScript, Node.js, and NestJS-style projects without adding another plugin or
turning editor policy into project policy.

## Requirements

- Ubuntu 22.04 or 24.04 for automatic transport-tool and Neovim provisioning
- Git, cURL, tar, gzip, unzip, and SHA-256 utilities
- Neovim 0.12+ (the automated path pins 0.12.3)
- ripgrep, GNU Make, and a C compiler
- Node.js >= 22.22.2 and npm
- tree-sitter CLI >= 0.26.1
- `fd` or Ubuntu's `fdfind` is optional; file search falls back to ripgrep
- network access while installing or updating

The installer provisions only small transport packages and Neovim. It reports
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
- Edit Lua, JavaScript, TypeScript, JSON, and JSONC with Treesitter highlighting,
  LSP diagnostics, navigation, and Blink completion where supported.
- Use TypeScript and ESLint source actions explicitly; the editor respects
  project-local TypeScript, ESLint, Prettier, and configuration files.
- Format explicitly with `<leader>cf`; format-on-save is intentionally absent.
- Inspect Git hunks and one-shot blame without adding a file explorer or Git UI.

The leader is `<Space>` and the local leader is `\`. The complete mapping
reference, including Blink's defaults, is in [docs/keymaps.md](docs/keymaps.md).

## Structure

```text
init.lua             Seven-line startup orchestrator
lua/config/          Plugin-independent editor behavior and lazy bootstrap
lua/plugins/         Six focused Coding MVP specifications
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

Go, Python, Docker, Kubernetes, Terraform, test runners, debuggers, and AI
tooling remain future milestones.

## Commands

```bash
make install    # link, synchronize, provision, and validate
make doctor     # check dependencies, tools, packages, parsers, and health
make test       # run two network-free isolated starts and runtime assertions
make update     # update from a clean worktree and show lockfile changes
make uninstall  # remove only this repository's config symlink
```

Inside Neovim, use `:Lazy`, `:Mason`, `:ConformInfo`, and focused
`:checkhealth vim.lsp`, `:checkhealth telescope`,
`:checkhealth vim.treesitter`, or `:checkhealth mason` diagnostics.

## Development

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) before making
changes. Review `lazy-lock.json` independently whenever plugin revisions move.
Common failures and recovery steps are in
[docs/troubleshooting.md](docs/troubleshooting.md).
