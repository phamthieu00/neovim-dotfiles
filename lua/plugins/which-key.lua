return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "Find / filesystem" },
      { "<leader>c", group = "Code" },
      { "<leader>b", group = "Buffers" },
      { "<leader>h", group = "Git hunks" },
    },
  },
}
