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

### Changed

- Installation now validates Coding MVP prerequisites before changing the
  configuration link, synchronizes plugins/parsers, and provisions four Mason
  packages.
- Update and CI workflows now maintain and validate plugins, parsers, language
  servers, formatters, and the pinned tree-sitter CLI.

### Fixed

### Removed
