# Plugins

This is a curated, modern Neovim plugin set. It includes focused daily-editing
integrations, the Catppuccin Mocha color scheme, icons, a centered command
line, session restore, and
optional CLI agent bridges. `lazy-lock.json` pins resolved revisions.

## Plugin manager

### lazy.nvim

- **Purpose:** bootstrap and synchronize all third-party code.
- **Configuration:** stable branch, focused imported specs, update checker disabled,
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
- **Troubleshooting:** confirm Make and a C compiler, then rebuild it in
  `:Lazy`.
- **Removal:** delete its dependency block and the protected extension load;
  Telescope will retain its default sorter.

## Filesystem and editing UX

### bufferline.nvim

- **Repository:** `akinsho/bufferline.nvim`
- **Purpose:** show open buffers as a compact tab-like line so several files
  remain visible without changing Neovim's native buffer model.
- **Configuration:** always shows the bufferline, reports LSP diagnostics, and
  reserves an offset label for Oil. It does not replace native windows or tab
  pages.
- **Dependency:** `nvim-tree/nvim-web-devicons` supplies filetype glyphs.
- **Troubleshooting/removal:** inspect `:Lazy` and `:messages` if the line does
  not appear; this plugin has no health provider. Remove this specification and
  its lockfile entry, then run blocking `:Lazy! sync`. Open buffers and native
  `[b`/`]b` navigation continue to work without it.

### persistence.nvim

- **Purpose:** save sessions automatically and restore them without a manual
  command when launching plain Neovim.
- **Configuration:** loads eagerly so plain `nvim` and directory launches such
  as `nvim .` can restore the current directory's session; explicit file
  arguments are never hijacked. It uses upstream save defaults.
- **Mappings:** `<leader>qs` loads the current session, `<leader>qS` selects a
  session, `<leader>ql` loads the last session, and `<leader>qd` stops saving.
- **Removal:** remove `lua/plugins/persistence.lua` and its lockfile entry.

### toggleterm.nvim

- **Purpose:** provide persistent, resizable terminal sessions without adding a
  separate terminal application or shell configuration.
- **Configuration:** lazy-loads on `<C-\>` or the terminal mappings, uses a
  horizontal 15-line terminal, starts in Insert mode, and supports terminal
  mappings for toggling the focused session.
- **Mappings:** `<C-\>` toggles the main terminal; `<leader>t1`/`t2`/`t3`
  select numbered terminals, `<leader>tn` toggles the main terminal, and
  `<leader>ts` selects an existing terminal.
- **Troubleshooting:** run `:ToggleTerm`, `:TermSelect`, and inspect
  `:messages` if the terminal does not open. The Codex and Claude panels remain
  separate integrations.
- **Removal:** remove `lua/plugins/terminal.lua`, its lock entry, and the
  terminal assertions from the smoke test.

### oil.nvim

- **Purpose:** edit a directory as a normal buffer so nearby files can be
  created, renamed, moved, or deleted without a permanent sidebar.
- **Why it exists:** Oil matches this repository's buffer-oriented model and
  keeps Telescope focused on finding things. It was chosen instead of a tree
  explorer because it adds filesystem operations without a second navigation
  UI framework or sidebar.
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
- **Configuration:** loads on `VeryLazy` and labels `<leader>a`, `<leader>f`,
  `<leader>c`, `<leader>b`, and `<leader>h` using the v3 `opts.spec` API. Existing `desc`
  values remain canonical; icons and popup styling are untouched.
- **Troubleshooting:** press `<leader>` and run `:checkhealth which-key`; if a
  mapping is missing, inspect its original `desc` and loading event.
- **Removal:** remove `lua/plugins/which-key.lua`, group-label references,
  health/smoke assertions, and its lock entry. Existing mappings continue to
  work normally.

### catppuccin/nvim

- **Purpose:** provide the active Catppuccin Mocha color scheme.
- **Why it exists:** a single maintained palette improves readability without
  adding a statusline, sidebar, or other UI framework.
- **Configuration:** loaded eagerly at priority 1000; `lua/plugins/theme.lua`
  sets `flavour = "mocha"` and activates `catppuccin-nvim`.
- **Troubleshooting:** run `:colorscheme catppuccin-nvim` and inspect
  `:echo g:colors_name`. If the theme is missing, use `:Lazy` to verify the
  checkout and rerun `:Lazy sync`.
- **Removal:** remove `lua/plugins/theme.lua`, its smoke/doctor assertions, and
  the lockfile entry. Neovim will fall back to its default colors.

### nvim-web-devicons

- **Purpose:** provide file and folder glyphs to Oil and bufferline.
- **Configuration:** loaded as a shared dependency; Oil sets `columns = { "icon" }`.
- **Troubleshooting:** icons require a terminal font with the relevant glyphs;
  inspect `:checkhealth nvim-web-devicons` and `:Oil` if symbols render as boxes.
- **Removal:** remove the dependency and Oil's icon column, then delete its
  lockfile and smoke entries if no other UI plugin uses it.

### noice.nvim and nui.nvim

- **Purpose:** render `:` as a centered command-line popup and provide a
  floating UI for command-line messages.
- **Configuration:** `noice.nvim` loads on `VeryLazy`, depends on `nui.nvim`,
  and uses the documented `cmdline_popup` view. Noice's other views remain at
  their defaults.
- **Troubleshooting:** run `:checkhealth noice`, `:Noice`, and inspect
  `:messages`. If the command line is at the bottom, confirm Noice is loaded
  with `:Lazy` and that `cmdline.view` is `cmdline_popup`.
- **Removal:** remove `lua/plugins/noice.lua`, its `nui.nvim` dependency,
  smoke/doctor checks, and both lock entries. Neovim will return to its native
  bottom command-line.

## AI coding agents

These integrations are thin Neovim front ends for the CLI tools the user
already authenticates and maintains. They do not add API keys, model
configuration, project manifests, or background requests during startup.

### claude-code.nvim

- **Repository:** `greggh/claude-code.nvim`
- **Purpose:** open Claude Code in an editor terminal, continue a conversation,
  and reload files changed by the agent.
- **Configuration:** loaded by `:ClaudeCode` or its mappings; Plenary is the
  existing utility dependency. `<leader>ac` toggles Claude Code and `<leader>cC`
  continues the latest conversation. The terminal opens as a 35%-wide vertical
  panel on the right; terminal-local navigation uses Neovim's native terminal
  windows.
- **External requirement:** the `claude` CLI must be installed and available on
  Neovim's `PATH`. The doctor reports it as a warning when missing; the
  installer never installs it.
- **Troubleshooting:** run `:ClaudeCode`, `:ClaudeCodeContinue`, and
  `:messages`; verify `command -v claude` from the same shell that starts
  Neovim. Do not put credentials in this repository.
- **Removal:** remove `lua/plugins/claude-code.lua`, its mappings and lock entry,
  then run blocking `:Lazy! sync`. Plenary remains because Telescope uses it.

### codex.nvim

- **Repository:** `nwiizo/codex.nvim`
- **Purpose:** keep the OpenAI Codex CLI's terminal or app-server workflow next
  to the active buffer, with file and visual-selection context commands.
- **Configuration:** dependency-free and lazy-loaded by its commands/mappings.
  `<leader>ax` focuses or hides Codex, `<leader>ab` adds the current buffer,
  visual `<leader>aa` adds a selection, and visual `<leader>as` sends it. The
  terminal backend is explicitly configured as a 35%-wide right-side split;
  Neovim can resize it with the mouse or native window commands. Codex's own
  approval and session UI remains intact.
- **External requirement:** the `codex` CLI must be installed and available on
  `PATH`. The doctor reports it as a warning when missing; no CLI or auth state
  is managed by this repository.
- **Troubleshooting:** use `:Codex`, `:CodexStatus`, and `:CodexHealth`; check
  `~/.codex/config.toml` and `command -v codex`. The plugin is community
  maintained and is not endorsed by OpenAI.
- **Removal:** remove `lua/plugins/codex.lua`, its mappings and lock entry, then
  run blocking `:Lazy! sync`. No other plugin depends on it.

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
