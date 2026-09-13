local cobalt_modules = {}

for module_name in pairs(package.loaded) do
  if module_name == "cobalt2" or vim.startswith(module_name, "cobalt2.") then
    table.insert(cobalt_modules, module_name)
  end
end

for _, module_name in ipairs(cobalt_modules) do
  package.loaded[module_name] = nil
end

require("colorbuddy").colorscheme("cobalt2")
