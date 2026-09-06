return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",
    transparent_background = false,
    integrations = {
      blink_cmp = true,
      gitsigns = true,
      native_lsp = { enabled = true },
      noice = true,
      telescope = true,
      which_key = true,
      bufferline = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin-nvim")
  end,
}
