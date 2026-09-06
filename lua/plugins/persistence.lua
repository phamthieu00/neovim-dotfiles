return {
  "folke/persistence.nvim",
  lazy = false,
  opts = {},
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    local function utility_only_session(path)
      if vim.fn.filereadable(path) == 0 then
        return false
      end

      local saw_utility = false
      for _, line in ipairs(vim.fn.readfile(path)) do
        local name = line:match("^file%s+(.+)$")
        if name then
          if name:match("^[%a][%w+.-]*://") then
            saw_utility = true
          else
            return false
          end
        end
      end
      return saw_utility
    end

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

      -- Do not resurrect sessions created by :checkhealth or another URI
      -- buffer. Those utility buffers are not useful as the default editor
      -- screen and can make a plain `nvim` launch appear blank.
      local session = persistence.current()
      if vim.fn.filereadable(session) == 0 then
        session = persistence.current({ branch = false })
      end
      if not utility_only_session(session) then
        persistence.load()
      end
    end)
  end,
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Load session" },
    { "<leader>qS", function() require("persistence").select() end, desc = "Select session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Load last session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Stop session persistence" },
  },
}
