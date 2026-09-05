# Installation

## Supported path

Automatic provisioning currently supports Ubuntu 22.04 and 24.04 on x86_64
and arm64. The architecture keeps OS detection isolated so macOS support can be
added without changing configuration logic.

Run:

```bash
make install
```

The installer performs these operations in order:

1. Installs missing Git, cURL, tar, checksum, and certificate packages with
   `apt-get` (using `sudo` when needed).
2. Uses an existing Neovim 0.12+ or downloads the pinned Neovim 0.12.3 archive,
   verifies its SHA-256 checksum, and installs it under `~/.local/opt`.
3. Creates `~/.local/bin/nvim` only when that path is unused; unrelated files
   and links are never replaced.
4. Moves an existing `~/.config/nvim` to a timestamped backup.
5. Links the repository to `~/.config/nvim`.
6. Bootstraps lazy.nvim and runs doctor and isolated smoke checks.

If validation fails after the config link changes, the installer removes its
link and restores the previous configuration. Re-running a successful install
is a no-op apart from validation.

If `~/.local/bin` is not on `PATH`, add this to the appropriate shell startup
file:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Backups

Backups have names such as:

```text
~/.config/nvim.backup.20260905-210000
```

A numeric suffix avoids collisions. Backups are never deleted automatically.

## Uninstall

```bash
make uninstall
```

Uninstall removes `~/.config/nvim` only when it is a symlink to this repository.
It does not restore a backup automatically because choosing the correct backup
requires user intent. Restore one after uninstalling with:

```bash
mv ~/.config/nvim.backup.TIMESTAMP ~/.config/nvim
```

The following Neovim-owned directories are preserved:

```text
~/.local/share/nvim
~/.local/state/nvim
~/.cache/nvim
```

## Other operating systems

Install Git and Neovim 0.12+ manually, ensure both are on `PATH`, and rerun the
installer. It will skip Ubuntu provisioning when every core requirement is
already available.
