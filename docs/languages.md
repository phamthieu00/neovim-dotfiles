# Languages

Milestone 3A makes TypeScript, Node.js, and NestJS-style editing practical while
keeping application dependencies and mutation policy outside the editor.

## Responsibility boundaries

| Area | Neovim provides | The project provides |
| --- | --- | --- |
| TypeScript/JavaScript | `ts_ls`, navigation, completion data, source actions | `package.json`, TypeScript version, `tsconfig.json`, framework packages |
| ESLint | `eslint` diagnostics, code actions, explicit fix-all | ESLint library, plugins, flat or legacy configuration |
| JSON/JSONC | `jsonls` validation/completion and Treesitter highlighting | Optional schema declarations and project configuration |
| Formatting | Manual Conform entry point and Mason Prettierd fallback | Preferred Prettier version, config, and plugins when installed locally |
| YAML | Treesitter highlighting and manual Prettier formatting | Schema/lint tooling; no YAML LSP is configured |

The configuration is package-manager neutral. npm is required by the Coding MVP
toolchain, while pnpm is reported as an optional convenience; projects may use
npm, pnpm, Yarn, or another workflow without Neovim creating or modifying their
dependency tree.

## TypeScript and NestJS workflow

Open Neovim within a project containing its normal manifest and TypeScript
configuration. The language server discovers a workspace TypeScript installation
when present and otherwise uses its bundled TypeScript. No custom SDK or root
selection is layered over upstream nvim-lspconfig behavior.

Useful actions include:

- `gd`, `gD`, `gy`, `gi`, and `gr` for definition-oriented navigation.
- `<leader>fs` and `<leader>fS` for document and workspace symbol search.
- `<leader>rn` and `<leader>ca` for rename and ordinary code actions.
- `<leader>ch` to toggle inlay hints when an attached server supports them.
- `:LspTypescriptSourceAction` for explicit whole-file TypeScript source actions,
  including organize-import choices offered by the server.

The fixture in `tests/fixtures/typescript/` is intentionally dependency-free. It
uses small local decorator functions to exercise NestJS-like syntax without
pretending to be a runnable application or installing framework packages.

`gD` remains the standard declaration mapping for clients that advertise the
protocol method. The currently provisioned TypeScript server does not advertise
a declaration provider, so its definition, type-definition, implementation,
reference, and source-definition paths are the practical TypeScript navigation
interfaces.

## ESLint

The Mason server is only the editor bridge. A real project must provide ESLint,
its plugins, and either a current flat configuration or a supported legacy
configuration. Upstream root and working-directory behavior is preserved for
workspaces and monorepos. Formatting is disabled in the ESLint client so it does
not compete with Conform.

Use `<leader>ca` for an offered fix at the cursor or selection, and
`:LspEslintFixAll` for an intentional full-file pass. No ESLint action runs on
save.

## Formatting and JSON

`<leader>cf` formats Lua with Stylua and JavaScript, JSX, TypeScript, TSX, JSON,
JSONC, or YAML with the first available `prettierd`/`prettier`. Formatter
resolution searches ancestor `node_modules` before `PATH`, preserving local
Prettier versions, configuration, and plugins. `:ConformInfo` shows the selected
formatter. Markdown is deliberately excluded, and format-on-save is disabled.

`jsonls` validates and completes JSON/JSONC without SchemaStore. Add schemas to
the application or a future focused server override only when a concrete project
needs them. YAML has formatting and parsing but no language server.

## Environment files

Neovim's built-in detection recognizes `.env`, `.env.example`, and common
environment-specific variants. This repository adds no custom detector or
filetype policy. Treat every environment file as sensitive: ignore real secret
files, commit only redacted examples, and never paste credentials into issue
reports or automated fixtures. Neovim does not load or transmit their values.

## Debugging

Use `:LspInfo`, `:checkhealth vim.lsp`, and `:Mason` to inspect clients and
executables. Use `:ConformInfo` for formatter resolution and
`:checkhealth vim.treesitter` for parser issues. If a server does not attach,
confirm filetype detection, the project root/configuration, and project-local
dependencies before adding editor overrides.

Format-on-save may be added later as a narrow Conform policy after its timeout,
fallback, and filetype scope are agreed and tested. It must not implicitly add
ESLint fix-all or TypeScript import organization.
