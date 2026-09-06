return {
  "folke/persistence.nvim",
  lazy = false,
  opts = {},
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    -- Restore plain `nvim` and directory launches such as `nvim .`.
    -- Explicit file arguments still win and are never hijacked.
    vim.schedule(function()
      local argc = vim.fn.argc()
      local argument = vim.fn.argv(0)
      local directory_arg = argc == 1
        and (vim.fn.isdirectory(argument) == 1 or argument:match("^oil://") ~= nil)
      if argc > 0 and not directory_arg then
        return
      end
      if not directory_arg and vim.api.nvim_buf_get_name(0) ~= "" then
        return
      end
      persistence.load()
    end)
  end,
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Load session" },
    { "<leader>qS", function() require("persistence").select() end, desc = "Select session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Load last session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Stop session persistence" },
  },
}
