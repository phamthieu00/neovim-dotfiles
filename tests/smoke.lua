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
  assert(package.loaded["config.statusline"], "statusline module not loaded")
  assert(vim.o.statusline:find("Statusline.mode", 1, true), "mode is missing from statusline")
  assert(vim.o.statusline:find("Statusline.branch", 1, true), "branch is missing from statusline")
  assert(vim.o.statusline:find("Statusline.diagnostics", 1, true), "diagnostics are missing from statusline")

  assert(require("telescope"))
  assert(require("blink.cmp"))
  assert(require("conform"))
  assert(require("gitsigns"))
  local gitsigns_config = require("gitsigns.config").config
  assert(gitsigns_config.signcolumn == true, "Gitsigns signcolumn markers must be enabled")
  assert(gitsigns_config.numhl == false, "Gitsigns number highlights must be disabled")
  assert(gitsigns_config.linehl == false, "Gitsigns line highlights must be disabled")
  assert(gitsigns_config.word_diff == false, "Gitsigns word diff must be disabled")
  assert(require("nvim-treesitter"))
  vim.cmd("Lazy! load nvim-lspconfig mason.nvim mason-lspconfig.nvim oil.nvim nvim-autopairs nvim-surround which-key.nvim noice.nvim bufferline.nvim nvim-web-devicons persistence.nvim toggleterm.nvim claude-code.nvim codex.nvim")
  assert(require("oil"))
  assert(require("nvim-autopairs"))
  assert(require("nvim-surround"))
  assert(require("which-key"))
  assert(require("colorbuddy"))
  assert(require("catppuccin"))
  assert(vim.g.colors_name == "cobalt2", "Cobalt2 colorscheme is not active")
  local cobalt_normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  vim.cmd.colorscheme("catppuccin-mocha")
  assert(vim.g.colors_name == "catppuccin-mocha", "Catppuccin colorscheme is unavailable")
  local catppuccin_normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  assert(not vim.deep_equal(catppuccin_normal, cobalt_normal), "Catppuccin did not replace Cobalt2 highlights")
  vim.cmd.colorscheme("cobalt2")
  assert(vim.g.colors_name == "cobalt2", "Cobalt2 colorscheme could not be restored")
  assert(
    vim.deep_equal(vim.api.nvim_get_hl(0, { name = "Normal", link = false }), cobalt_normal),
    "Cobalt2 highlights were not restored"
  )
  assert(require("noice"))
  assert(require("bufferline"))
  assert(require("nvim-web-devicons"))
  assert(vim.opt.showtabline:get() == 2, "bufferline must keep open buffers visible")
  assert(require("persistence"))
  assert(require("toggleterm"))
  assert(vim.fn.exists(":ToggleTerm") == 2, "ToggleTerm command unavailable")
  assert(vim.fn.exists(":TermSelect") == 2, "TermSelect command unavailable")
  assert(vim.fn.maparg("<C-\\>", "n") ~= "", "Ctrl-\\ terminal mapping unavailable")
  assert(require("claude-code"))
  assert(require("claude-code").config.window.position == "vertical", "Claude Code must use a right-side vertical panel")
  assert(require("claude-code").config.window.split_ratio == 0.35, "Claude Code panel width changed unexpectedly")
  assert(require("codex"))
  local codex_config = require("codex.config").get()
  assert(codex_config.terminal.layout == "split", "Codex must use a split terminal")
  assert(codex_config.terminal.split_side == "right", "Codex must open on the right")
  assert(codex_config.terminal.split_width_percentage == 0.35, "Codex panel width changed unexpectedly")
  for _, command in ipairs({ "ClaudeCode", "ClaudeCodeContinue", "Codex", "CodexFocus", "CodexAdd", "CodexHealth" }) do
    assert(vim.fn.exists(":" .. command) == 2, command .. " command unavailable")
  end
  for _, mapping in ipairs({ "<Space>qs", "<Space>qS", "<Space>ql", "<Space>qd", "<Space>ac", "<Space>cC", "<Space>ax", "<Space>ab" }) do
    assert(vim.fn.maparg(mapping, "n") ~= "", mapping .. " mapping unavailable")
  end
  -- Noice defers setup until VimEnter in headless startup; replay that event
  -- here so command registration is tested without a timing sleep.
  vim.api.nvim_exec_autocmds("VimEnter", { modeline = false })
  assert(vim.wait(1000, function()
    return vim.fn.exists(":Noice") == 2
  end), "Noice command unavailable")
  local which_key_spec = require("which-key.config").options.spec
  local expected_groups = {
    a = "AI agents",
    f = "Find / filesystem",
    c = "Code",
    b = "Buffers",
    g = "Git",
    h = "Git hunks",
  }
  for prefix, group in pairs(expected_groups) do
    local found = false
    for _, item in ipairs(which_key_spec) do
      if item[1] == "<leader>" .. prefix and item.group == group then
        found = true
        break
      end
    end
    assert(found, "which-key group metadata unavailable for " .. prefix)
  end

  for _, server in ipairs(lsp_servers) do
    assert(vim.lsp.config[server], server .. " config unavailable")
  end
  assert(vim.lsp.config.eslint.settings.format == false, "ESLint formatting must remain disabled")

  for _, command in ipairs({ "Telescope", "ConformInfo", "Mason", "Oil", "WhichKey", "Noice" }) do
    assert(vim.fn.exists(":" .. command) == 2, command .. " command unavailable")
  end
  assert(require("noice.config").options.cmdline.view == "cmdline_popup", "Noice cmdline popup is not enabled")

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
  assert_mapping("<leader>fe")
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

  for _, lhs in ipairs({ "ys", "ds", "cs" }) do
    assert(vim.fn.maparg(lhs, "n") ~= "", lhs .. " surround mapping unavailable")
  end
end

function M.typescript(fixture_root)
  assert(vim.bo.filetype == "typescript", "TypeScript filetype detection failed")
  assert(vim.fs.root(0, { "tsconfig.json" }) == fixture_root, "tsconfig project detection failed")
  assert_parser("typescript")
  assert(vim.wait(10000, function()
    return vim.fn.maparg("]h", "n") ~= ""
      and vim.fn.maparg("[h", "n") ~= ""
      and vim.fn.maparg("<leader>hp", "n") ~= ""
      and vim.fn.maparg("<leader>hb", "n") ~= ""
  end), "Gitsigns hunk/blame mappings unavailable")

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
