return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				python = { "black" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				bash = { "shfmt" },
				lua = { "stylua" },
				javascript = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				dart = { "dart_format" },
				rust = { "rustfmt" },
			},
			formatters = {
				dart_format = {
					command = "dart",
					args = { "format" },
				},
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		})
	end,
}
