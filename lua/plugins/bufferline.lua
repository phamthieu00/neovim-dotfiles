return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    options = {
      mode = "buffers",
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      diagnostics = "nvim_lsp",
      separator_style = "slant",
      offsets = {
        {
          filetype = "oil",
          text = "File Explorer",
          text_align = "center",
          separator = true,
        },
      },
    },
  },
}
