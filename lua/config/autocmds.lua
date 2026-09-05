local highlight_group = vim.api.nvim_create_augroup("config-highlight-yank", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_group,
  desc = "Highlight text after yanking",
  callback = function()
    vim.highlight.on_yank()
  end,
})
