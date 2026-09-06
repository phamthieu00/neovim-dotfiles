return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    lsp = {
      signature = { enabled = false },
      hover = { enabled = false },
    },
    presets = {
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
}
