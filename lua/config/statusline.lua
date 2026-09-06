local M = {}

local modes = {
  n = "NORMAL",
  no = "OPERATOR",
  i = "INSERT",
  ic = "INSERT",
  ix = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\022"] = "V-BLOCK",
  c = "COMMAND",
  s = "SELECT",
  S = "S-LINE",
  ["\019"] = "S-BLOCK",
  R = "REPLACE",
  Rc = "REPLACE",
  Rx = "REPLACE",
  rv = "V-REPLACE",
  r = "PROMPT",
  t = "TERMINAL",
  ["!"] = "SHELL",
}

function M.mode()
  return modes[vim.fn.mode(1)] or "UNKNOWN"
end

function M.branch()
  local branch = vim.b.gitsigns_head or vim.g.gitsigns_head or ""
  if branch == "" then
    return ""
  end
  return "branch:" .. branch
end

function M.diagnostics()
  local labels = {
    { vim.diagnostic.severity.ERROR, "E" },
    { vim.diagnostic.severity.WARN, "W" },
    { vim.diagnostic.severity.INFO, "I" },
    { vim.diagnostic.severity.HINT, "H" },
  }
  local parts = {}
  for _, item in ipairs(labels) do
    local count = #vim.diagnostic.get(0, { severity = item[1] })
    if count > 0 then
      parts[#parts + 1] = item[2] .. ":" .. count
    end
  end
  return table.concat(parts, " ")
end

function M.filetype()
  return vim.bo.filetype ~= "" and vim.bo.filetype or "text"
end

_G.Statusline = M

vim.o.statusline = table.concat({
  "%#StatusLineMode# %{v:lua.Statusline.mode()} ",
  "%#StatusLineGit#%{v:lua.Statusline.branch()} ",
  "%#StatusLine#%f%m%r",
  " %y",
  " %= ",
  "%#StatusLineDiagnostic#%{v:lua.Statusline.diagnostics()} ",
  "%#StatusLine#%{v:lua.Statusline.filetype()} %l:%c %p%% ",
})

local function refresh()
  vim.cmd("redrawstatus")
end

local group = vim.api.nvim_create_augroup("config-statusline", { clear = true })
vim.api.nvim_create_autocmd({
  "BufEnter",
  "BufFilePost",
  "DiagnosticChanged",
  "ModeChanged",
  "TextChanged",
  "TextChangedI",
  "User",
}, {
  group = group,
  pattern = { "*", "GitSignsUpdate" },
  callback = refresh,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    vim.api.nvim_set_hl(0, "StatusLineMode", { link = "String" })
    vim.api.nvim_set_hl(0, "StatusLineGit", { link = "Directory" })
    vim.api.nvim_set_hl(0, "StatusLineDiagnostic", { link = "DiagnosticWarn" })
  end,
})

vim.api.nvim_set_hl(0, "StatusLineMode", { link = "String" })
vim.api.nvim_set_hl(0, "StatusLineGit", { link = "Directory" })
vim.api.nvim_set_hl(0, "StatusLineDiagnostic", { link = "DiagnosticWarn" })

return M
