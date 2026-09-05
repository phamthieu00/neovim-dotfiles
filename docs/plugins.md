# Plugins

Milestone 2 admits only search, parsing, LSP/tool management, completion,
formatting, and Git signs. `lazy-lock.json` pins resolved revisions.

## Plugin manager

### lazy.nvim

- **Purpose:** bootstrap and synchronize all third-party code.
- **Configuration:** stable branch, six imported specs, update checker disabled,
  and a lockfile committed at the repository root.
- **Troubleshooting:** use `:Lazy`, `:Lazy sync`, and inspect the build log.
- **Removal:** removing it means removing every plugin specification and the
  bootstrap in `config/lazy.lua`; it is not independently removable today.

## Search

### telescope.nvim

- **Purpose:** files, grep, buffers, history, help, and diagnostics pickers.
- **Configuration:** stable release and defaults; hidden file search excludes
  `.git` and chooses `fd`, `fdfind`, then ripgrep.
- **Troubleshooting:** run `:checkhealth telescope` and verify the selected
  finder is on `PATH`.
- **Removal:** remove `lua/plugins/telescope.lua`, its documented mappings, and
  its Plenary/FZF dependency lock entries.

### plenary.nvim

- **Purpose:** required Telescope Lua utility library.
- **Configuration:** no repository-specific options.
- **Troubleshooting:** Telescope load failures usually expose Plenary errors in
  `:messages` or `:Lazy`.
- **Removal:** remove it only with Telescope unless another future plugin needs
  it.

### telescope-fzf-native.nvim

- **Purpose:** native FZF sorting for Telescope.
- **Configuration:** built with `make`; loaded through `pcall` so a failed
  extension does not prevent Telescope from starting.
- **Troubleshooting:** confirm GNU Make and a C compiler, then rebuild it in
  `:Lazy`.
- **Removal:** delete its dependency block and the protected extension load;
  Telescope will retain its default sorter.

## Syntax parsing

### nvim-treesitter

- **Purpose:** parser lifecycle and syntax highlighting.
- **Configuration:** rewritten `main` API, non-lazy loading, synchronous build
  updates for Lua, Vim, Vimdoc, Bash, JSON, YAML, JavaScript, TypeScript, TSX,
  Markdown, and Markdown Inline. A scoped `FileType` autocmd calls
  `vim.treesitter.start()`; indentation and folding are absent.
- **Troubleshooting:** require tree-sitter CLI >= 0.26.1 and a C compiler; use
  `:checkhealth vim.treesitter` and the Lazy build log.
- **Removal:** remove `lua/plugins/treesitter.lua` and parser assertions from
  installer-independent validation; Neovim then falls back to legacy syntax.

## LSP and tool management

### nvim-lspconfig

- **Purpose:** upstream definitions for `lua_ls` and `ts_ls`.
- **Configuration:** loaded before Mason integration; Blink capabilities are
  advertised globally with `vim.lsp.config('*', ...)`, diagnostics are shared,
  and mappings are buffer-local on `LspAttach`.
- **Troubleshooting:** use `:checkhealth vim.lsp` and `:LspInfo` from a recognized
  Lua or TypeScript project.
- **Removal:** remove `lua/plugins/lsp.lua`, `after/lsp/lua_ls.lua`, LSP mapping
  docs, server Mason provisioning, and LSP assertions together.

### mason.nvim

- **Purpose:** install language servers and formatters in Neovim's data tree.
- **Configuration:** default UI; scripts require `lua-language-server`,
  `typescript-language-server`, `stylua`, and `prettierd`.
- **Troubleshooting:** inspect `:Mason` and `:checkhealth mason`; Node >= 22.22.2
  is required by the JavaScript tools.
- **Removal:** first choose a documented external installation strategy for all
  four tools, then remove script/doctor/smoke provisioning and its dependency.

### mason-lspconfig.nvim

- **Purpose:** map Mason packages to Neovim server identifiers.
- **Configuration:** ensures and automatically enables only `lua_ls` and
  `ts_ls`.
- **Troubleshooting:** verify both Mason package names and resolved
  `vim.lsp.config` entries.
- **Removal:** replace its ensure/enable behavior explicitly with
  `vim.lsp.enable()` before removing the dependency.

## Completion

### blink.cmp

- **Purpose:** completion from LSP, paths, built-in snippets, and buffer words.
- **Configuration:** stable `1.*`, default keymap, documentation after 500 ms,
  and signature help disabled. No external snippet collection is installed.
- **Troubleshooting:** run `:checkhealth blink.cmp`, verify LSP attachment, and
  confirm Insert mode triggers the plugin.
- **Removal:** remove `lua/plugins/completion.lua`, its LSP dependency and
  capability merge, plus Blink keymap documentation.

## Formatting

### conform.nvim

- **Purpose:** one explicit asynchronous formatting interface.
- **Configuration:** Stylua for Lua and first available `prettierd`/`prettier`
  for JavaScript, TypeScript, React variants, and JSON. LSP is a fallback only;
  format-on-save is disabled.
- **Troubleshooting:** run `:ConformInfo`; Mason provides Stylua and Prettierd,
  while Prettier is an optional project/global fallback.
- **Removal:** remove `lua/plugins/format.lua`, formatter Mason provisioning,
  formatter checks, and the `<leader>cf` documentation.

## Git

### gitsigns.nvim

- **Purpose:** default sign-column change markers, hunk navigation/preview, and
  one-shot full line blame.
- **Configuration:** default signs and buffer-local mappings using `nav_hunk()`.
- **Troubleshooting:** open a tracked file inside a Git worktree and inspect
  `:checkhealth gitsigns` or `:messages`.
- **Removal:** remove `lua/plugins/git.lua` and its four documented mappings;
  no other component depends on it.
