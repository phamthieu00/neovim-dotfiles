return {
  {
    "lalitmee/cobalt2.nvim",
    lazy = false,
    priority = 1000,
    dependencies = {
      { "tjdevries/colorbuddy.nvim", tag = "v1.0.0" },
    },
    config = function()
      require("colorbuddy").colorscheme("cobalt2")
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 900,
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
  },
}
