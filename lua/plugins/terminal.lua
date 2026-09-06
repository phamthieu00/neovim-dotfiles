return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",

    opts = {
      size = 15,
      open_mapping = [[<c-\>]],
      direction = "horizontal",
      shade_terminals = true,
      start_in_insert = true,
      terminal_mappings = true,
      persist_size = true,
      close_on_exit = true,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        direction = "float",
        hidden = true,
        close_on_exit = true,
        on_open = function()
          vim.cmd("startinsert")
        end,
      })

      vim.api.nvim_create_user_command("LazyGit", function()
        if vim.fn.executable("lazygit") ~= 1 then
          vim.notify("lazygit is not installed or is not on PATH", vim.log.levels.ERROR)
          return
        end
        lazygit:toggle()
      end, { desc = "Open LazyGit" })
    end,
    keys = {
      {
        "<C-\\>",
        "<cmd>ToggleTerm<cr>",
        desc = "Toggle terminal",
      },

      {
        "<leader>gg",
        "<cmd>LazyGit<cr>",
        desc = "Open LazyGit",
      },

      {
        "<leader>t1",
        "<cmd>1ToggleTerm<cr>",
        desc = "Terminal 1",
      },

      {
        "<leader>t2",
        "<cmd>2ToggleTerm<cr>",
        desc = "Terminal 2",
      },

      {
        "<leader>t3",
        "<cmd>3ToggleTerm<cr>",
        desc = "Terminal 3",
      },

      {
        "<leader>tn",
        "<cmd>ToggleTerm<cr>",
        desc = "Toggle terminal",
      },

      {
        "<leader>ts",
        "<cmd>TermSelect<cr>",
        desc = "Select terminal",
      },

      {
        "<leader>ta",
        "<cmd>ToggleTermToggleAll<cr>",
        desc = "Toggle all terminals",
      },

      {
        "<Esc>",
        [[<C-\><C-n>]],
        mode = "t",
        desc = "Exit terminal mode",
      }
    },
  },
}
