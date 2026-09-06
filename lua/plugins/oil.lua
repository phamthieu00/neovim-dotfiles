return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<leader>fe",
      "<cmd>Oil<CR>",
      desc = "Explore files",
    },
  },
  opts = {
    columns = { "icon" },
  },
}
