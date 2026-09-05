# Troubleshooting

Start with:

```bash
make doctor
```

`ERROR` entries block a healthy Milestone 1 installation. `WARNING` entries
describe tools reserved for later coding milestones.

## Neovim is too old

Run `make install`. On supported Ubuntu systems it installs the pinned Neovim
release under `~/.local/opt` and links it from `~/.local/bin`. If the old binary
still runs, put `~/.local/bin` before system directories in `PATH` and start a
new shell.

## The installer refuses a path

The installer does not replace unrelated `~/.local/bin/nvim` entries. Inspect
that path and move it yourself only after deciding it is safe. Likewise,
`make uninstall` refuses a real directory or a symlink owned by another config.

## lazy.nvim cannot be cloned

Confirm that Git is available and that GitHub is reachable:

```bash
git --version
git ls-remote https://github.com/folke/lazy.nvim.git HEAD
```

Then rerun `make test`. The smoke test uses temporary XDG directories, so a
failed clone does not alter normal Neovim data.

## Existing configuration disappeared

The installer moves it to `~/.config/nvim.backup.TIMESTAMP` and prints the exact
path. Run `make uninstall`, inspect available backups, and move the intended
backup back to `~/.config/nvim`.

## Resetting Neovim state

Neovim data, state, and cache can help diagnose plugin bootstrap problems, but
this project never deletes them automatically. Back them up before manually
removing anything under `~/.local/share/nvim`, `~/.local/state/nvim`, or
`~/.cache/nvim`.
