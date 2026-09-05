# Architecture

The configuration uses small modules with one clear owner for each kind of
behavior. This keeps startup understandable and prevents unrelated features
from accumulating in a single Lua file.

## Startup flow

```text
init.lua
  -> config/options.lua
  -> config/keymaps.lua
  -> config/autocmds.lua
  -> config/lazy.lua
       -> lazy.nvim
       -> plugin specifications (Milestone 2)
```

`init.lua` sets leader keys before mappings or plugins can read them, then
loads each core module in a predictable order. It contains no behavior of its
own beyond that orchestration.

## Ownership rules

- `lua/config/` owns behavior that works without third-party plugins.
- `lua/plugins/` will own one lazy.nvim specification per plugin or cohesive
  plugin group.
- `after/lsp/<server>.lua` will own one language server's settings, using
  `vim.lsp.config()` and `vim.lsp.enable()` rather than deprecated setup calls.
- `after/ftplugin/<filetype>.lua` will own buffer-local editor settings for a
  language or filetype.
- `scripts/` owns installation and operational workflows; the Makefile only
  exposes convenient names for those scripts.

The last three configuration locations are intentionally not created until a
feature needs them. Empty scaffolding suggests capabilities the project does
not yet provide.

## Where a future change belongs

```text
General editor behavior?          -> lua/config/
Third-party plugin?               -> lua/plugins/
Specific language server?         -> after/lsp/
Filetype-local editor setting?     -> after/ftplugin/
Installation or maintenance task? -> scripts/
```

Plugin-specific mappings stay beside their plugin specification. LSP mappings
are registered on `LspAttach`. Global, plugin-independent mappings remain in
`lua/config/keymaps.lua`.

## Reproducibility

lazy.nvim is currently the only third-party component and is bootstrapped from
its stable branch. Its empty Milestone 1 lock state is kept under Neovim's state
directory. Milestone 2 will move the lockfile into the repository when actual
plugin revisions need to be recorded and reviewed.
