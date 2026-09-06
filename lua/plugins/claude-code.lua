return {
  "greggh/claude-code.nvim",
  cmd = {
    "ClaudeCode",
    "ClaudeCodeContinue",
    "ClaudeCodeResume",
    "ClaudeCodeVerbose",
  },
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Code: toggle" },
    { "<leader>cC", "<cmd>ClaudeCodeContinue<cr>", desc = "Claude Code: continue" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    window = {
      position = "vertical",
      split_ratio = 0.35,
    },
  },
  config = function(_, opts)
    require("claude-code").setup(opts)
  end,
}
