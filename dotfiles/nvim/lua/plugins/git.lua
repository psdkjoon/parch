return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = " " },
				change = { text = "󰏬 " },
				delete = { text = "󰍵 " },
				topdelete = { text = "󰍵 " },
				changedelete = { text = "󰏬 " },
				untracked = { text = "󰀧 " },
			},
			signs_staged_enable = true,
			signcolumn = true,
			current_line_blame = false,
			current_line_blame_opts = {
				delay = 500,
				virt_text_pos = "eol",
			},
		},
	},
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gclog", "Gblame" },
	},
}
