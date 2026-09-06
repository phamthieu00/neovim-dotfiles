local highlight_group = vim.api.nvim_create_augroup("config-highlight-yank", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_group,
  desc = "Highlight text after yanking",
  callback = function()
    vim.highlight.on_yank()
  end,
})

local hygiene_group = vim.api.nvim_create_augroup("config-editor-hygiene", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
  group = hygiene_group,
  desc = "Do not continue comments on a new line",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = hygiene_group,
  desc = "Restore the last cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = hygiene_group,
  desc = "Equalize windows after terminal resize",
  command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  group = hygiene_group,
  pattern = { "help", "qf", "checkhealth", "man", "lspinfo", "notify" },
  desc = "Close utility buffers with q",
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true, desc = "Close window" })
  end,
})
