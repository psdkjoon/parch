return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local tools = {
				servers = {
					"pyright",
					"clangd",
					"bashls",
					"lua_ls",
					"html",
					"cssls",
					"ts_ls",
					"jsonls",
					"dartls",
					"rust_analyzer",
				},
				all = {
					"tree-sitter-cli",
					"black",
					"clang-format",
					"shfmt",
					"stylua",
					"prettier",
					"pyright",
					"clangd",
					"bashls",
					"lua_ls",
					"html",
					"cssls",
					"ts_ls",
					"jsonls",
					"rust_analyzer",
				},
			}
			require("mason").setup({ ui = { border = "rounded" } })
			require("mason-tool-installer").setup({
				ensure_installed = tools.all,
				auto_update = true,
			})
			require("mason-lspconfig").setup({
				automatic_enable = false,
			})
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			for _, server in ipairs(tools.servers) do
				vim.lsp.config(server, {
					capabilities = capabilities,
				})
				vim.lsp.enable(server)
			end
			vim.diagnostic.config({
				update_in_insert = true,
				severity_sort = true,
				float = { border = "rounded" },
			})
		end,
	},
}
