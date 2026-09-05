local M = {}

local lsp_servers = { "lua_ls", "ts_ls", "eslint", "jsonls" }
local mason_packages = {
  "lua-language-server",
  "typescript-language-server",
  "eslint-lsp",
  "json-lsp",
  "stylua",
  "prettierd",
}
local parsers = {
  "lua",
  "vim",
  "vimdoc",
  "bash",
  "json",
  "yaml",
  "javascript",
  "typescript",
  "tsx",
  "markdown",
  "markdown_inline",
}

local function wait_for_client(name)
  local attached = vim.wait(10000, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = name }) > 0
  end)
  assert(attached, name .. " did not attach")
  return vim.lsp.get_clients({ bufnr = 0, name = name })[1]
end

local function assert_mapping(lhs)
  assert(vim.fn.maparg(lhs, "n") ~= "", lhs .. " mapping unavailable")
end

local function assert_parser(language)
  local parser = vim.treesitter.get_parser(0, language)
  local tree = assert(parser:parse()[1], language .. " parser returned no tree")
  assert(not tree:root():has_error(), language .. " fixture contains parser errors")
end

local function assert_formatter_chain(filetype)
  vim.bo.filetype = filetype
  local conform = require("conform")
  local configured = conform.formatters_by_ft[filetype]
  assert(vim.deep_equal(vim.list_slice(configured, 1, 2), { "prettierd", "prettier" }))
  assert(configured.stop_after_first == true, filetype .. " formatter chain does not stop after first")
end

function M.runtime()
  for _, module in ipairs({ "config.options", "config.keymaps", "config.autocmds", "config.lazy" }) do
    assert(package.loaded[module], module .. " not loaded")
  end

  assert(require("telescope"))
  assert(require("blink.cmp"))
  assert(require("conform"))
  assert(require("gitsigns"))
  assert(require("nvim-treesitter"))
  vim.cmd("Lazy! load nvim-lspconfig mason.nvim mason-lspconfig.nvim")

  for _, server in ipairs(lsp_servers) do
    assert(vim.lsp.config[server], server .. " config unavailable")
  end
  assert(vim.lsp.config.eslint.settings.format == false, "ESLint formatting must remain disabled")

  for _, command in ipairs({ "Telescope", "ConformInfo", "Mason" }) do
    assert(vim.fn.exists(":" .. command) == 2, command .. " command unavailable")
  end

  local registry = require("mason-registry")
  for _, package in ipairs(mason_packages) do
    assert(registry.is_installed(package), package .. " is not installed")
  end

  local installed = {}
  for _, parser in ipairs(require("nvim-treesitter").get_installed()) do
    installed[parser] = true
  end
  for _, parser in ipairs(parsers) do
    assert(installed[parser], parser .. " parser is not installed")
  end

  local filetypes = {
    ["file.js"] = "javascript",
    ["file.jsx"] = "javascriptreact",
    ["file.ts"] = "typescript",
    ["file.tsx"] = "typescriptreact",
    ["package.json"] = "json",
    ["tsconfig.json"] = "jsonc",
    ["file.yaml"] = "yaml",
    [".env"] = "env",
    [".env.example"] = "env",
    [".env.development"] = "env",
    [".env.production"] = "env",
    [".env.test"] = "env",
  }
  for filename, expected in pairs(filetypes) do
    assert(vim.filetype.match({ filename = filename }) == expected, filename .. " filetype mismatch")
  end

  assert_mapping("<leader>fs")
  assert_mapping("<leader>fS")
  assert_mapping("<leader>cf")
  for _, filetype in ipairs({
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "yaml",
  }) do
    assert_formatter_chain(filetype)
  end
  assert(require("conform").formatters_by_ft.markdown == nil, "Markdown formatting must remain disabled")
end

function M.typescript(fixture_root)
  assert(vim.bo.filetype == "typescript", "TypeScript filetype detection failed")
  assert(vim.fs.root(0, { "tsconfig.json" }) == fixture_root, "tsconfig project detection failed")
  assert_parser("typescript")

  local ts_client = wait_for_client("ts_ls")
  for _, method in ipairs({
    "textDocument/completion",
    "textDocument/hover",
    "textDocument/definition",
    "textDocument/implementation",
    "textDocument/references",
    "textDocument/rename",
    "textDocument/codeAction",
  }) do
    assert(ts_client:supports_method(method, 0), "ts_ls does not support " .. method)
  end

  local eslint_client = wait_for_client("eslint")
  assert(eslint_client:supports_method("textDocument/codeAction", 0), "ESLint code actions unavailable")
  assert(eslint_client.config.settings.format == false, "ESLint client formatting is enabled")
  assert(vim.fn.exists(":LspTypescriptSourceAction") == 2, "TypeScript source actions unavailable")
  assert(vim.fn.exists(":LspEslintFixAll") == 2, "ESLint fix-all command unavailable")
  -- The current TypeScript server has no declarationProvider; retain and test
  -- the shared mapping for servers that do advertise the standard method.
  assert_mapping("gD")
  assert_mapping("gy")
  assert_mapping("<leader>ch")
end

function M.json()
  assert(vim.bo.filetype == "jsonc", "JSONC filetype detection failed")
  assert_parser("json")
  local client = wait_for_client("jsonls")
  assert(client:supports_method("textDocument/completion", 0), "JSON completion unavailable")
end

return M
