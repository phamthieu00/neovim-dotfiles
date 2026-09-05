# Neovim Configuration

A small, explicit Neovim configuration maintained as a software project. The
current release contains the repository foundation and editor defaults only;
coding plugins will be added separately after the core is stable.

## Requirements

- Ubuntu 22.04 or 24.04 for automatic dependency installation
- Git
- Neovim 0.12 or newer
- Network access during the first start to bootstrap `lazy.nvim`

The installer can provision Git, download utilities, and a verified Neovim
0.12.3 release when they are missing. Other operating systems can use the
configuration after installing Git and Neovim manually.

## Installation

```bash
git clone <repository-url> ~/projects/neovim-config
cd ~/projects/neovim-config
make install
```

The installer links this repository to `~/.config/nvim`. It backs up an
existing configuration instead of deleting it. See
[docs/installation.md](docs/installation.md) for provisioning, backup, and
uninstall details.

## Project structure

```text
init.lua             Small entry point
lua/config/          Plugin-independent editor behavior
scripts/             Installation and maintenance commands
tests/               Isolated startup smoke test
docs/                Architecture and operational guidance
.github/workflows/   Continuous integration
```

Future plugins will live under `lua/plugins/`; server and filetype-specific
configuration will live under `after/lsp/` and `after/ftplugin/`. Those
directories are deliberately absent until their milestones begin.

## Keymaps

| Mapping | Action |
| --- | --- |
| `<leader>w` | Save the current file |
| `<leader>q` | Quit the current window |
| `<Esc>` | Clear search highlighting |
| `<C-h/j/k/l>` | Move between windows |
| `[b` / `]b` | Select the previous / next buffer |
| `<leader>bd` | Delete the current buffer |

The leader key is `<Space>` and the local leader is `\`.

## Installed plugins

Only [lazy.nvim](https://github.com/folke/lazy.nvim) is bootstrapped as the
plugin manager. It currently receives an empty plugin specification. No UI,
LSP, completion, formatting, debugging, testing, or AI plugins are installed.

## Language support

No language-specific behavior is configured yet. TypeScript, Go, Python,
Docker, Kubernetes, and Terraform support belong to later, independent
milestones.

## Common commands

```bash
make install
make doctor
make test
make update
make uninstall
```

## Updating

Create a short-lived branch and start from a clean worktree before running
`make update`. Review every resulting change before committing it. Detailed
guidance is in [docs/maintenance.md](docs/maintenance.md).

## Troubleshooting

Run `make doctor` first. It distinguishes required failures from warnings for
tools that only future milestones need. See
[docs/troubleshooting.md](docs/troubleshooting.md) for common fixes.

## Development

Read [docs/architecture.md](docs/architecture.md) before changing ownership
boundaries and [CONTRIBUTING.md](CONTRIBUTING.md) before submitting changes.
Agents must also follow [AGENTS.md](AGENTS.md).
