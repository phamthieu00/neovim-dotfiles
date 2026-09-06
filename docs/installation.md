# Installation

## Prerequisites

Automatic provisioning supports Ubuntu 22.04/24.04 and macOS on x86_64 and
arm64. On macOS, the installer bootstraps Homebrew when necessary and installs
the required transport and Coding MVP tools in one command. On Ubuntu, major
shared runtimes remain explicit prerequisites.

For Ubuntu, install the Coding MVP toolchain:

```bash
sudo apt-get update
sudo apt-get install -y build-essential fd-find ripgrep
```

Install Node.js >= 22.22.2 with npm using your preferred version manager or the
official distribution. Install tree-sitter CLI >= 0.26.1 from its official
release or with a toolchain you control. Confirm:

```bash
node --version
npm --version
tree-sitter --version
rg --version
make --version
cc --version
```

If Node is managed by NVM, the configuration automatically discovers
`~/.nvm/versions/node/*/bin/node`. You can also set
`NVIM_NODE=/absolute/path/to/node` for a deterministic override. The installer
does not change your shell startup files.

Node, npm, compilers, ripgrep, Make, and tree-sitter are deliberately not
installed automatically on Ubuntu because they are major shared development
tools. On macOS they are installed through Homebrew to keep `make install` a
single command; set `NEOVIM_NO_BREW_BOOTSTRAP=1` to require an existing
Homebrew installation. The installer uses Homebrew's `tree-sitter-cli` formula
(the `tree-sitter` library formula does not provide the CLI). `fd` or Ubuntu's
`fdfind` is optional; Telescope falls back to `rg --files`.

## Install sequence

Run `make install`. The script:

1. Installs missing transport tools through `apt-get` on supported Ubuntu
   systems, or through Homebrew on macOS.
2. Uses Neovim 0.12+ or installs a verified Neovim 0.12.3 archive under
   `~/.local/opt/nvim-v0.12.3` (Linux) or the same user-local prefix on macOS,
   linking an unused `~/.local/bin/nvim`. The official macOS archives are
   architecture-specific and checksum-verified.
3. Verifies all major Coding MVP prerequisites before touching the config path.
4. Moves an existing platform config path (`~/.config/nvim` on Linux or
   `~/Library/Application Support/nvim` on macOS) to a collision-safe
   timestamped backup.
5. Symlinks this repository to that platform config path.
6. Runs blocking `:Lazy! sync`, which installs plugins, builds native FZF, and
   updates/installs the maintained Treesitter parsers.
7. Installs `lua-language-server`, `typescript-language-server`, `eslint-lsp`,
   `json-lsp`, `stylua`, and `prettierd` through Mason.
8. Runs doctor and network-free smoke tests.

If validation fails after a new link is created, the installer removes only its
own link and restores the previous config. Re-running a successful install is
idempotent apart from synchronization and validation.

If `~/.local/bin` is missing from `PATH`, add:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

For the intended workflow, enter the project directory and run `nvim .`.
Persistence restores the Neovim buffers and layout for that directory without
requiring a terminal multiplexer or a special terminal emulator.

Mason owns editor-facing executables only. Each application still owns its
TypeScript, ESLint, Prettier, framework, and plugin dependencies through npm,
pnpm, Yarn, or another project-selected package manager. The editor neither
creates `node_modules` nor rewrites package manifests.

Daily UX plugins do not install external executables. Oil and bufferline can
show glyphs when the terminal uses a Nerd Font; install/configure a suitable
font manually if icons render incorrectly. Noice's centered command line does
not require a font change. If system clipboard integration is useful,
install the provider appropriate for the session manually, for example
`wl-clipboard` on Wayland or `xclip`/`xsel` on X11. The installer never adds
these optional packages automatically.

## AI CLI integrations

Lazy installs the Claude Code and Codex Neovim bridges during `:Lazy! sync`, but
it does not install either CLI or manage authentication. Install the tools using
their official instructions and verify they are visible to the same environment
that launches Neovim:

```bash
command -v claude && claude --version
command -v codex && codex --version
```

Missing CLIs are warnings in `make doctor`, not installation failures. Use
`:ClaudeCode` or `<leader>ac` for Claude Code, and `:Codex` or `<leader>ax` for
Codex. Keep credentials, session transcripts, and CLI configuration under their
normal user directories; none belong in this repository.

## Backups and uninstall

Backups look like `~/.config/nvim.backup.20260905-210000` on Linux or
`~/Library/Application Support/nvim.backup.20260905-210000` on macOS, with a
numeric suffix on collision. They are never deleted automatically.

`make uninstall` removes the config symlink only when it resolves to this
repository. A successful install writes an ownership marker in the Neovim data
directory; when present, uninstall removes this project's lazy.nvim checkout,
Mason packages, parser/site data, and project-owned state/cache directories.
It does not remove unrelated Neovim data, backups, Homebrew, Node/npm, Claude,
Codex, or application `node_modules`. Restore a chosen backup explicitly:

```bash
mv ~/.config/nvim.backup.TIMESTAMP ~/.config/nvim
```

If an ownership marker is absent, uninstall refuses to guess and preserves
plugin/data directories. This protects an existing shared Neovim installation.

## Other operating systems

Install every prerequisite and Neovim 0.12+ manually, ensure they are on
`PATH`, then run the installer. Unsupported systems receive explicit missing
tool guidance; OS dispatch is isolated for future platform support.
