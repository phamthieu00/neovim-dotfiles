# Maintenance

Keep updates small, reviewable, reversible, and reproducible.

## Routine update

Start from a clean worktree:

```bash
git switch -c chore/update-neovim
git pull --ff-only
make update
git diff -- lazy-lock.json
git diff
git status --short
```

`make update` refuses uncommitted changes. It runs blocking lazy.nvim updates,
which also execute the Treesitter parser build hook, confirms the six Mason
packages, runs doctor and smoke tests, and displays repository and lockfile
changes. It never creates branches or commits and does not update system tools.

Review the four Milestone 4 lockfile entries independently. A plugin update is
not complete until its startup behavior, mappings, and removal path remain
documented.

Treat `lazy-lock.json` as reviewed source: identify each revision movement and
retain the previous lockfile when an update fails. Mason package and parser
artifacts are external state validated by tooling rather than committed files.

## Health and formatter inspection

Use focused checks inside Neovim:

```vim
:checkhealth vim.lsp
:checkhealth telescope
:checkhealth vim.treesitter
:checkhealth mason
:checkhealth which-key
:Mason
:ConformInfo
```

The doctor verifies hard dependency versions, the config link, startup, plugin
modules, LSP configs, Mason packages, parsers, formatter availability, clipboard
provider, and these health providers. Smoke tests reuse installed plugin data while isolating
config, state, and cache, so they do not need network access.

## Before completing a change

```bash
bash -n scripts/*.sh tests/*.sh
make doctor
make test
make test
git diff --check
git diff
git status --short
```

Compile every changed Lua file with `loadfile()` under Neovim. After install or
update changes, also run blocking `:Lazy! sync`, reconcile Mason packages, and
search the repository for caches, downloaded archives, plugin data, swap files,
and build output. Record anything that could only be checked interactively.

## Save-time policy

Formatting, ESLint fixes, and TypeScript source actions are intentionally
manual. If format-on-save becomes an explicit project decision later, add a
narrow Conform `format_on_save` policy in `lua/plugins/format.lua`, document
timeout and LSP-fallback behavior, and test it independently. Do not fold ESLint
fix-all or import organization into that hook; those actions can change program
semantics and remain explicit commands.
