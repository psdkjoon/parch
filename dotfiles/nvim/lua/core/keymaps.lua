local M = {}

local runner = require("core.runner")
local keymap = vim.keymap
local ui = vim.ui

keymap.set({ "n", "i", "v" }, "<F2>", function()
	runner.run()
end, { desc = "Run file / project" })

keymap.set({ "n", "i", "v" }, "<F3>", function()
	ui.input({ prompt = "Flags: " }, function(input)
		if input ~= nil then
			runner.run(input)
		end
	end)
end, { desc = "Run file / project with flags" })

keymap.set({ "n", "i", "v" }, "<F4>", function()
	runner.stop()
end, { desc = "Stop running job" })

keymap.set({ "n", "i", "v" }, "<leader>rt", function()
	runner.toggle_window()
end, { desc = "Toggle runner terminal window" })

keymap.set("n", "<leader>fd", function()
	require("telescope.builtin").diagnostics()
end, { desc = "Diagnostics" })

keymap.set("n", "<leader>fc", function()
	require("telescope.builtin").live_grep({ default_text = "-- \\|// \\|# " })
end, { desc = "Find Comments" })

keymap.set("n", "<leader>fn", function()
	require("telescope.builtin").treesitter({ symbols = { "function" } })
end, { desc = "Find Functions" })

keymap.set("n", "<leader>fm", function()
	require("telescope.builtin").treesitter({ symbols = { "method" } })
end, { desc = "Find Methods" })

keymap.set("n", "<leader>fl", function()
	require("telescope.builtin").treesitter({ symbols = { "class" } })
end, { desc = "Find Classes" })

keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find Files" })

keymap.set("n", "<leader>fh", function()
	require("telescope.builtin").find_files({ hidden = true })
end, { desc = "Find Files (hidden)" })

keymap.set("n", "<leader>gh", function()
	require("telescope.builtin").git_bcommits()
end, { desc = "File history (Telescope)" })

keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Move to window left" })
keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Move to window below" })
keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Move to window above" })
keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Move to window right" })

keymap.set("n", "<C-n>", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

function M.nvim_tree_on_attach(bufnr)
	local api = require("nvim-tree.api")
	api.config.mappings.default_on_attach(bufnr)
	local function opts(desc)
		return { desc = "NvimTree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	keymap.set("n", "a", api.fs.create, opts("Create file/folder"))
	keymap.set("n", "r", api.fs.rename, opts("Rename"))
	keymap.set("n", "<CR>", api.node.open.edit, opts("Open file/folder"))
	keymap.set("n", "<Right>", api.node.open.edit, opts("Expand folder / open file"))
	keymap.set("n", "<Left>", api.node.navigate.parent_close, opts("Collapse folder / go to parent"))
end

return M
