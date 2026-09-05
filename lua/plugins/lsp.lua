return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
    {
      "mason-org/mason.nvim",
      cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
      opts = {},
    },
    "mason-org/mason-lspconfig.nvim",
  },
  config = function()
    vim.diagnostic.config({
      signs = true,
      underline = true,
      severity_sort = true,
      virtual_text = {
        spacing = 2,
        source = false,
      },
      float = { source = true },
    })

    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    local group = vim.api.nvim_create_augroup("config-lsp-attach", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = group,
      desc = "Configure buffer-local LSP mappings",
      callback = function(args)
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("gr", vim.lsp.buf.references, "Find references")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>e", function()
          vim.diagnostic.open_float({ scope = "cursor" })
        end, "Show current diagnostic")
        map("]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")
        map("[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Previous diagnostic")
      end,
    })

    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "ts_ls" },
      automatic_enable = { "lua_ls", "ts_ls" },
    })
  end,
}
