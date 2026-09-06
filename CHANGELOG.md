# Changelog

Meaningful changes to this project are recorded here.

## Unreleased

### Added

- Repository foundation, maintenance scripts, documentation, and CI.
- Minimal plugin-independent Neovim options, mappings, and yank highlighting.
- lazy.nvim bootstrap, now backed by focused plugin specifications.
- Telescope search with native FZF acceleration and ripgrep fallback.
- Treesitter highlighting and eleven maintained parser installations.
- Modern Mason-managed `lua_ls` and `ts_ls` configuration with Blink
  capabilities, diagnostics, and buffer-local navigation mappings.
- Blink completion, manual Conform formatting, and Gitsigns hunk navigation.
- Committed plugin lockfile, focused plugin/keymap documentation, Coding MVP
  health checks, fixtures, and network-free runtime smoke tests.
- TypeScript/Node/NestJS workflow with `eslint` and `jsonls`, project-local tool
  discovery, explicit source actions, symbol search, and conditional inlay hints.
- JSONC/YAML formatting, JSONC parsing coverage, language documentation, and a
  dependency-free decorator-heavy TypeScript fixture.
- Daily coding UX with Oil filesystem editing, nvim-autopairs, nvim-surround,
  which-key leader groups, and optional clipboard-provider diagnostics.
- Catppuccin Mocha as the focused color scheme, without additional UI plugins.
- Optional Oil file icons through `mini.icons` and a centered `:` command line
  through Noice with its `nui.nvim` dependency.
- Bufferline with web-devicons so open buffers remain visible as tab-like entries.
- Persistence for project sessions and dynamic PATH/NVM Node discovery.
- Optional Claude Code and Codex CLI integrations with lazy command loading,
  explicit context mappings, and non-blocking doctor warnings when either CLI
  is absent.

### Changed

- Installation now validates Coding MVP prerequisites before changing the
  configuration link, synchronizes plugins/parsers, and provisions six Mason
  packages.
- Update and CI workflows now maintain and validate plugins, parsers, language
  servers, formatters, and the pinned tree-sitter CLI.
- The plugin lockfile now records the focused Daily UX integrations,
  Catppuccin, icon support, Noice, bufferline, persistence, and AI bridges while
  existing search, completion, formatting, LSP, and Git ownership remains
  unchanged.
- New UI and workflow dependencies are locked separately; existing plugin
  revisions remain unchanged.
- Legacy modules that require lsp-zero, hardcoded Node releases, AI credentials,
  or pre-0.12 Treesitter APIs remain intentionally unimported.
- Oil icons now use the shared `nvim-web-devicons` dependency instead of the
  previous `mini.icons` integration.
- Persistence now auto-restores the current project session for plain `nvim`
  launches while preserving explicit manual session mappings.

### Fixed

### Removed

- Redundant status, indentation, diagnostics, diff, search/replace, and undo UI
  plugins were removed to keep the configuration small and explicit.
