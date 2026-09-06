local function executable(path)
  return path and path ~= "" and vim.fn.executable(path) == 1
end

local function add_bin_to_path(node)
  -- Resolve a user-facing symlink such as ~/.local/bin/node so sibling
  -- executables installed by npm (for example claude) are also discoverable.
  local resolved = vim.fn.resolve(node)
  local bin = vim.fs.dirname(resolved ~= "" and resolved or node)
  local path = vim.env.PATH or ""
  if not path:find(bin, 1, true) then
    vim.env.PATH = bin .. ":" .. path
  end
end

local candidates = {}
if vim.env.NVIM_NODE then
  table.insert(candidates, vim.env.NVIM_NODE)
end

local system_node = vim.fn.exepath("node")
if system_node ~= "" then
  table.insert(candidates, system_node)
end

for _, node in ipairs(vim.fn.glob(vim.fn.expand("~/.nvm/versions/node/*/bin/node"), true, true)) do
  table.insert(candidates, node)
end

for _, node in ipairs(candidates) do
  if executable(node) then
    add_bin_to_path(node)
    vim.g.nvim_node_path = vim.fn.resolve(node)
    return node
  end
end

vim.g.nvim_node_path = nil
return nil
