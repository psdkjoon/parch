return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			ensure_installed = {
				"python",
				"cpp",
				"c",
				"bash",
				"lua",
				"html",
				"css",
				"javascript",
				"json",
				"rust",
				"dart",
				"toml",
				"yaml",
				"markdown",
				"gitcommit",
				"gitignore",
			},
			highlight = { enable = true },
		})
	end,
}
