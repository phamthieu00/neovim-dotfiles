# Plugins

Milestone 4 retains the Coding MVP and adds four independent daily-editing
specifications. `lazy-lock.json` pins resolved revisions.

## Plugin manager

### lazy.nvim

- **Purpose:** bootstrap and synchronize all third-party code.
- **Configuration:** stable branch, ten imported specs, update checker disabled,
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

## Filesystem and editing UX

### oil.nvim

- **Purpose:** edit a directory as a normal buffer so nearby files can be
  created, renamed, moved, or deleted without a permanent sidebar.
- **Why it exists:** Oil matches this repository's buffer-oriented model and
  keeps Telescope focused on finding things. It was chosen instead of a tree
  explorer because it adds filesystem operations without a second navigation
  UI or icon dependency.
- **Configuration:** loaded at startup as recommended by Oil, with default
  display and buffer keymaps. `<leader>fe` runs `:Oil` for the current working
  directory.
- **Troubleshooting:** use `:Oil`, `g?` inside an Oil buffer, and `:messages`;
  write the Oil buffer with `:w` to apply edits. Do not test destructive
  operations in an important checkout.
- **Removal:** remove `lua/plugins/oil.lua`, its `<leader>fe` documentation,
  smoke assertions, and the lockfile entry. Telescope remains the file search
  tool.

### nvim-autopairs

- **Purpose:** insert matching `()`, `[]`, `{}`, quotes, and backticks while
  typing.
- **Why it exists:** it removes repetitive delimiter entry while leaving
  native motions, text objects, and Blink completion in charge of their own
  behavior.
- **Configuration:** loads on `InsertEnter` with default rules. No language-
  specific rules, Treesitter checks, or nvim-cmp adapter are added. Blink's
  completion-accept bracket behavior remains independent.
- **Troubleshooting:** inspect `:messages` after entering Insert mode and test
  a disposable TypeScript buffer; verify closing delimiters are skipped rather
  than duplicated.
- **Removal:** remove `lua/plugins/autopairs.lua`, its lock entry, and smoke
  module assertions. No other plugin depends on it.

### nvim-surround

- **Purpose:** add, delete, and change surrounding delimiters using operators.
- **Why it exists:** standard `ys`, `ds`, and `cs` operations cover common
  editing friction without custom text objects or a larger editing framework.
- **Configuration:** stable v4 series, loaded on `VeryLazy`, with default
  mappings and surrounds.
- **Troubleshooting:** use `:h nvim-surround.usage` and confirm the cursor is
  positioned for the intended motion or text object.
- **Removal:** remove `lua/plugins/surround.lua`, surround documentation,
  smoke mapping assertions, and its lock entry.

### which-key.nvim

- **Purpose:** reveal available mappings after a prefix is typed.
- **Why it exists:** the existing descriptions and semantic namespaces become
  discoverable without adding a command palette or remapping muscle memory.
- **Configuration:** loads on `VeryLazy` and labels only `<leader>f`, `<leader>c`,
  `<leader>b`, and `<leader>h` using the v3 `opts.spec` API. Existing `desc`
  values remain canonical; icons and popup styling are untouched.
- **Troubleshooting:** press `<leader>` and run `:checkhealth which-key`; if a
  mapping is missing, inspect its original `desc` and loading event.
- **Removal:** remove `lua/plugins/which-key.lua`, group-label references,
  health/smoke assertions, and its lock entry. Existing mappings continue to
  work normally.

## Syntax parsing

### nvim-treesitter

- **Purpose:** parser lifecycle and syntax highlighting.
- **Configuration:** rewritten `main` API, non-lazy loading, synchronous build
  updates for Lua, Vim, Vimdoc, Bash, JSON, YAML, JavaScript, TypeScript, TSX,
  Markdown, and Markdown Inline. JSONC highlighting reuses the JSON parser. A
  scoped `FileType` autocmd calls `vim.treesitter.start()`; indentation and
  folding are absent.
- **Troubleshooting:** require tree-sitter CLI >= 0.26.1 and a C compiler; use
  `:checkhealth vim.treesitter` and the Lazy build log.
- **Removal:** remove `lua/plugins/treesitter.lua` and parser assertions from
  installer-independent validation; Neovim then falls back to legacy syntax.

## LSP and tool management

### nvim-lspconfig

- **Purpose:** upstream definitions for `lua_ls`, `ts_ls`, `eslint`, and
  `jsonls`.
- **Configuration:** loaded before Mason integration; Blink capabilities are
  advertised globally with `vim.lsp.config('*', ...)`, diagnostics are shared,
  and mappings are buffer-local on `LspAttach`. TypeScript uses upstream
  workspace discovery, ESLint formatting is disabled, and JSON schemas are not
  supplemented with SchemaStore.
- **Troubleshooting:** use `:checkhealth vim.lsp` and `:LspInfo` from a recognized
  project. Use `:LspTypescriptSourceAction` and `:LspEslintFixAll` for explicit
  whole-file actions.
- **Removal:** remove `lua/plugins/lsp.lua`, relevant `after/lsp/` overrides,
  LSP mapping docs, Mason provisioning, and LSP assertions together.

### mason.nvim

- **Purpose:** install language servers and formatters in Neovim's data tree.
- **Configuration:** default UI; scripts require `lua-language-server`,
  `typescript-language-server`, `eslint-lsp`, `json-lsp`, `stylua`, and
  `prettierd`.
- **Troubleshooting:** inspect `:Mason` and `:checkhealth mason`; Node >= 22.22.2
  is required by the JavaScript tools.
- **Removal:** first choose a documented external installation strategy for all
  six tools, then remove script/doctor/smoke provisioning and its dependency.

### mason-lspconfig.nvim

- **Purpose:** map Mason packages to Neovim server identifiers.
- **Configuration:** ensures and automatically enables only `lua_ls`, `ts_ls`,
  `eslint`, and `jsonls`.
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
  for JavaScript, TypeScript, React variants, JSON, JSONC, and YAML. The
  formatter definitions search ancestor `node_modules` before `PATH`, allowing
  project-local Prettier versions and plugins to win. LSP is a fallback only;
  format-on-save is disabled and Markdown is excluded.
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
