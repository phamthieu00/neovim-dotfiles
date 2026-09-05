# Agent Guidelines

## Project goal

Maintain a minimal, explicit, and reproducible Neovim development environment.
Treat this repository as long-lived software, not as a snippet collection.

## Architecture

- `init.lua` only sets leaders and loads `lua/config/*`; keep it under 30 lines.
- `lua/config/` contains plugin-independent options, global mappings, generic
  autocmds, and lazy.nvim bootstrap logic.
- `lua/plugins/` is reserved for focused lazy.nvim specifications.
- `after/lsp/` is reserved for individual language-server configurations.
- `after/ftplugin/` is reserved for filetype-local editor settings.
- `scripts/`, `tests/`, and `docs/` own operations, validation, and rationale.

Do not create future directories until a concrete feature needs them. Read
`docs/architecture.md` before changing these ownership boundaries.

## Change rules

- Inspect the existing architecture and worktree before editing.
- Keep changes small, reviewable, reversible, documented, and tested.
- Avoid giant Lua modules and unrelated edits.
- Prefer built-in Neovim behavior when it adequately solves the problem.
- Prefer modern Neovim APIs. LSP work must use `vim.lsp.config()` and
  `vim.lsp.enable()` rather than deprecated `require("lspconfig").setup()`
  patterns.
- Keep language-server settings and filetype settings isolated.
- Document every new plugin and keymap; update README and detailed docs when
  behavior changes.
- Preserve and review `lazy-lock.json` after Milestone 2 introduces it.
- Never make installer or uninstaller behavior destructive or silently replace
  unrelated user data.
- Do not change unrelated files or add speculative features.

## Plugin policy

Before adding a plugin, answer:

1. What concrete problem does it solve?
2. Can Neovim solve the problem without a plugin?
3. Can an installed plugin solve it?
4. What maintenance cost does it add?
5. Is it actively maintained?
6. Does it support the targeted Neovim version?

Add the plugin only when the answers justify it. Keep plugin-specific mappings
with the plugin specification and explain how to remove the plugin.

## Validation

Before completing a change, run:

```bash
bash -n scripts/*.sh tests/*.sh
make test
git diff --check
```

Run `make doctor` when the installed configuration or external tooling is
relevant. Report every check that could not run. Inspect `git status` for
unexpected generated files and review lockfile changes explicitly.
