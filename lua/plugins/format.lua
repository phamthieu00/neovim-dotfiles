local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({
          async = true,
          lsp_format = "fallback",
          stop_after_first = true,
        })
      end,
      mode = { "n", "v" },
      desc = "Code format",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = prettier,
      javascriptreact = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      json = prettier,
      jsonc = prettier,
      yaml = prettier,
    },
  },
}
