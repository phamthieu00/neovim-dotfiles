# Installation

## Prerequisites

Automatic provisioning supports Ubuntu 22.04 and 24.04 on x86_64 and arm64.
Before running the installer, install the Coding MVP toolchain:

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

Node, npm, compilers, ripgrep, Make, and tree-sitter are deliberately not
installed automatically because they are major shared development tools. `fd`
or Ubuntu's `fdfind` is optional; Telescope falls back to `rg --files`.

## Install sequence

Run `make install`. The script:

1. Installs missing Git, cURL, tar, gzip, unzip, checksum, and certificate tools
   through `apt-get` on supported Ubuntu systems.
2. Uses Neovim 0.12+ or installs verified Neovim 0.12.3 under
   `~/.local/opt/nvim-v0.12.3`, linking an unused `~/.local/bin/nvim`.
3. Verifies all major Coding MVP prerequisites before touching the config path.
4. Moves an existing `~/.config/nvim` to a collision-safe timestamped backup.
5. Symlinks this repository to `~/.config/nvim`.
6. runs blocking `:Lazy! sync`, which installs plugins, builds native FZF, and
   updates/installs the maintained Treesitter parsers.
7. Installs `lua-language-server`, `typescript-language-server`, `stylua`, and
   `prettierd` through Mason.
8. Runs doctor and network-free smoke tests.

If validation fails after a new link is created, the installer removes only its
own link and restores the previous config. Re-running a successful install is
idempotent apart from synchronization and validation.

If `~/.local/bin` is missing from `PATH`, add:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Backups and uninstall

Backups look like `~/.config/nvim.backup.20260905-210000`, with a numeric suffix
on collision. They are never deleted automatically.

`make uninstall` removes `~/.config/nvim` only when it is a symlink resolving to
this repository. It preserves data, state, cache, plugins, Mason tools, and
backups. Restore a chosen backup explicitly:

```bash
mv ~/.config/nvim.backup.TIMESTAMP ~/.config/nvim
```

## Other operating systems

Install every prerequisite and Neovim 0.12+ manually, ensure they are on
`PATH`, then run the installer. Unsupported systems receive explicit missing
tool guidance; OS dispatch is isolated for future macOS support.
