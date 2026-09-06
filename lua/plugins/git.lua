return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")
      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("]h", function()
        gitsigns.nav_hunk("next")
      end, "Next Git hunk")
      map("[h", function()
        gitsigns.nav_hunk("prev")
      end, "Previous Git hunk")
      map("<leader>hp", gitsigns.preview_hunk, "Preview Git hunk")
      vim.keymap.set("n", "<leader>hb", function()
        gitsigns.blame_line({ full = true })
      end, { buffer = bufnr, desc = "Blame current line" })
    end,
  },
}
