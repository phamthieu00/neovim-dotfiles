local parsers = {
  "lua",
  "vim",
  "vimdoc",
  "bash",
  "json",
  "yaml",
  "javascript",
  "typescript",
  "tsx",
  "markdown",
  "markdown_inline",
}

local filetypes = {
  "lua",
  "vim",
  "help",
  "vimdoc",
  "sh",
  "bash",
  "json",
  "yaml",
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "markdown",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = function()
    local treesitter = require("nvim-treesitter")
    treesitter.update():wait(300000)
    treesitter.install(parsers):wait(300000)
  end,
  config = function()
    require("nvim-treesitter").setup()

    vim.treesitter.language.register("bash", "sh")
    vim.treesitter.language.register("javascript", "javascriptreact")
    vim.treesitter.language.register("tsx", "typescriptreact")

    local group = vim.api.nvim_create_augroup("config-treesitter-highlight", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = filetypes,
      desc = "Enable Treesitter highlighting for supported filetypes",
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
