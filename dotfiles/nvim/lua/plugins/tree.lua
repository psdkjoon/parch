return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("nvim-tree").setup({
			view = {
				width = 32,
				side = "left",
			},
			renderer = {
				group_empty = true,
				highlight_git = true,
				icons = {
					show = {
						git = true,
						folder = true,
						file = true,
						folder_arrow = true,
					},
					glyphs = {
						git = {
							unstaged = "󰏬 ",
							staged = "󱗜 ",
							unmerged = "󱎙 ",
							renamed = "󰑕 ",
							untracked = "󰀧 ",
							deleted = "󰍵 ",
							ignored = "󰎃 ",
						},
					},
				},
			},
			git = {
				enable = true,
				ignore = false,
				timeout = 400,
			},
			diagnostics = {
				enable = true,
				show_on_dirs = true,
			},
			filters = {
				dotfiles = false,
				custom = { "^.git$" },
			},
			actions = {
				open_file = {
					quit_on_open = false,
					resize_window = true,
				},
			},
			update_focused_file = {
				enable = true,
			},
			on_attach = function(bufnr)
				require("core.keymaps").nvim_tree_on_attach(bufnr)
			end,
		})

		local min_width = 100
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				if vim.o.columns >= min_width then
					local cur_win = vim.api.nvim_get_current_win()
					require("nvim-tree.api").tree.open()
					vim.api.nvim_set_current_win(cur_win)
				end
			end,
		})
		vim.api.nvim_create_autocmd("QuitPre", {
			nested = true,
			callback = function()
				local wins = vim.api.nvim_list_wins()
				local tree_wins = {}
				for _, w in ipairs(wins) do
					local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
					if bufname:match("NvimTree_") ~= nil then
						table.insert(tree_wins, w)
					end
				end
				if #tree_wins == #wins - 1 then
					for _, w in ipairs(tree_wins) do
						pcall(vim.api.nvim_win_close, w, true)
					end
				end
			end,
		})
	end,
}
