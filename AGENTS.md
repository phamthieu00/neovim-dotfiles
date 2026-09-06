# Agent Guidelines

## Project goal

Maintain a minimal, explicit, reproducible Neovim development environment.
Treat this repository as long-lived software, not a snippet collection.

The current workflow is a selective, modern Neovim configuration. Keep its
ownership boundaries explicit and never edit a user's shell configuration as
part of a Neovim change.

## Architecture boundaries

- Keep `init.lua` as the seven-line leader and module-loading entry point; never
  put feature logic there.
- Keep plugin-independent options, mappings, autocmds, and lazy bootstrap in
  `lua/config/`.
- Keep one plugin or cohesive integration per file in `lua/plugins/`.
- Keep server-specific settings in `after/lsp/<server>.lua`; use upstream
  defaults when no override is needed.
- Add `after/ftplugin/<filetype>.lua` only for real buffer-local editor settings.
- Keep operational behavior in scripts and expose only thin Make targets.
- Do not add empty scaffolding or speculative language configuration.

Read `docs/architecture.md` before moving responsibility between these areas.

## Change rules

- Inspect the worktree and current behavior before editing.
- Keep changes focused, reversible, documented, and testable.
- Prefer built-in Neovim behavior when it solves the problem adequately.
- Use modern Neovim 0.12 APIs. LSP configuration must use `vim.lsp.config()`
  and `vim.lsp.enable()` conventions, diagnostics must use
  `vim.diagnostic.jump()`, and Treesitter highlighting must use
  `vim.treesitter.start()`.
- Keep plugin mappings beside their specifications and LSP mappings on
  `LspAttach`; global plugin-independent mappings belong in `config/keymaps.lua`.
- Document every plugin, dependency, external requirement, command, and keymap.
- Preserve and review the committed `lazy-lock.json` separately during updates.
- Never silently replace or delete unrelated configuration, binaries, backups,
  plugin data, state, or cache.
- Do not add UI suites, file explorers, extra diagnostics UI, format-on-save,
  snippets collections, or language tooling outside the active milestone.
- Keep TypeScript, ESLint, Prettier, and package-manager dependencies
  project-owned. Do not create manifests, lockfiles, or `node_modules` for a
  user's application.
- Preserve explicit formatting, ESLint fix-all, and TypeScript source actions;
  do not introduce save-time mutation without a separately approved policy.
- Never expose or commit `.env` secrets; fixtures and documentation must use
  inert placeholder values only.
- Telescope is the fuzzy-search owner; Oil is the filesystem-editing owner.
  Do not add another file-tree plugin or duplicate filesystem shell mappings.
- Do not add motion plugins before native motions and text objects are shown to
  be insufficient in a real workflow.
- Do not add cosmetic plugins, icon dependencies, statuslines, or themes as
  part of a functional milestone unless the user explicitly requests them.
- AI CLI integrations are allowed only when explicitly requested. Keep Claude
  Code and Codex bridges separate, lazy, and removable; never commit API keys,
  CLI state, prompts, transcripts, or shell auto-start configuration.

## Plugin admission policy

Before adding a plugin, answer:

1. What concrete problem does it solve?
2. Can Neovim or an installed plugin already solve it?
3. What runtime, build, and transitive dependencies does it add?
4. What maintenance and startup cost does it add?
5. Is it actively maintained and compatible with Neovim 0.12?
6. How is it validated, documented, updated, and safely removed?

Add it only when the answers justify the ongoing ownership cost.

## Installer and tooling policy

Check major Coding MVP prerequisites before changing the config symlink. The
installer may provision transport utilities and pinned Neovim on supported
Ubuntu systems. On macOS, the explicit one-command installer may bootstrap
Homebrew and the required Coding MVP tools; never edit shell startup files.
Back up existing config paths and restore them if validation of a new link
fails. Uninstall may remove only a symlink resolving to this repository and
project-owned plugin data recorded by the install ownership marker; preserve
unrelated Neovim data, backups, and user-managed runtimes.

## Mandatory validation

Before completing a change, inspect every changed file and run:

```bash
bash -n scripts/*.sh tests/*.sh
make doctor
make test
make test
nvim --headless -u NONE "+lua assert(loadfile('path/to/file.lua'))" +qa
git diff --check
git diff
git status --short
```

For dependency changes, run blocking `:Lazy! sync`, provision the six required
Mason packages, and inspect `lazy-lock.json` separately. The required server
configs are `lua_ls`, `ts_ls`, `eslint`, and `jsonls`; the required Mason
packages are `lua-language-server`, `typescript-language-server`, `eslint-lsp`,
`json-lsp`, `stylua`, and `prettierd`. Check for generated
data, caches, archives, swap files, and build artifacts inside the repository.
For Daily UX changes, also assert the plugin modules, Oil command, `<leader>fe`,
bufferline loading, surround mappings, which-key group metadata, and any
explicitly requested UI additions such as icons or command-line rendering.
For explicitly requested AI integrations, assert their modules, lazy command
stubs, documented mappings, and clean startup without invoking either CLI.
Report interactive checks that could not be performed; do not imply that a
headless assertion validated visible UI behavior.
