local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repository = "https://github.com/folke/lazy.nvim.git"
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    repository,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    error(("Unable to clone lazy.nvim:\n%s"):format(output))
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {},
  -- Milestone 2 will move this into the repository once plugins need locking.
  lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",
  checker = { enabled = false },
  change_detection = { notify = false },
})
