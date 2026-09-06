local map = vim.keymap.set

local silent = { silent = true, noremap = true }

map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("n", "<C-s>", "<cmd>write<CR>", { desc = "Save file" })
map({ "n", "i", "x", "s" }, "<C-z>", "<cmd>undo<CR>", { desc = "Undo" })

-- Keep the cursor centered while navigating and searching.
map("n", "<C-d>", "<C-d>zz", silent)
map("n", "<C-u>", "<C-u>zz", silent)
map("n", "n", "nzzzv", silent)
map("n", "N", "Nzzzv", silent)
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

map("v", "<", "<gv", silent)
map("v", ">", ">gv", silent)
map("v", "J", ":m '>+1<CR>gv=gv", silent)
map("v", "K", ":m '<-2<CR>gv=gv", silent)

map("n", "<C-h>", "<C-w>h", { desc = "Focus window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus window right" })

map("n", "+", "<cmd>vertical resize +5<CR>", { desc = "Increase window width" })
map("n", "_", "<cmd>vertical resize -5<CR>", { desc = "Decrease window width" })
map("n", "=", "<cmd>resize +5<CR>", { desc = "Increase window height" })
map("n", "-", "<cmd>resize -5<CR>", { desc = "Decrease window height" })

map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

map("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>s", "<cmd>split<CR>", { desc = "Horizontal split" })
