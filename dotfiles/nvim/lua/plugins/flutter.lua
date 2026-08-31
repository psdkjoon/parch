return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		require("flutter-tools").setup({
			ui = {
				border = "rounded",
				notification_style = "native",
			},
			decorations = {
				statusline = {
					app_version = false,
					device = true,
				},
			},
			widget_guides = { enabled = true },
			closing_tags = {
				highlight = "Comment",
				prefix = "// ",
				enabled = true,
			},
			lsp = {
				capabilities = capabilities,
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
				},
			},
		})
	end,
}
