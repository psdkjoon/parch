return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
				integrations = {
					mason = true,
					nvimtree = true,
					which_key = true,
					gitsigns = true,
					lualine = true,
					native_lsp = { enabled = true },
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			win = {
				no_overlap = true,
				height = { min = 4, max = 25 },
			},
			layout = {
				width = { min = 20 },
				spacing = 3,
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local function diff_source()
				local gitsigns = vim.b.gitsigns_status_dict
				if gitsigns then
					return {
						added = gitsigns.added,
						modified = gitsigns.changed,
						removed = gitsigns.removed,
					}
				end
			end
			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = "",
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "diagnostics" },
					lualine_c = {},
					lualine_x = {},
					lualine_y = { { "diff", source = diff_source } },
					lualine_z = { "location" },
				},
				extensions = { "nvim-tree" },
			})
		end,
	},
	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				filetypes = { "*" },
				user_default_options = {
					RGB = true,
					RRGGBB = true,
					names = false,
					RRGGBBAA = false,
					AARRGGBB = false,
					rgb_fn = true,
					hsl_fn = true,
					css = true,
					css_fn = true,
					mode = "background",
					tailwind = "both",
				},
			})
		end,
	},
	{ "tpope/vim-sleuth" },
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			vim.notify = notify
			notify.setup({
				background_colour = "#000000",
				fps = 120,
				icons = {
					ERROR = " ",
					WARN = " ",
					INFO = " ",
					DEBUG = " ",
					TRACE = "✎ ",
				},
				render = "default",
				timeout = 2000,
				top_down = false,
				level = 2,
				minimum_width = 50,
				stages = "slide",
				time_formats = {
					notification = "%H:%M",
					notification_history = "%FT%T",
				},
			})
			local levels = { "ERROR", "WARN", "INFO", "DEBUG", "TRACE" }
			for _, level in ipairs(levels) do
				vim.api.nvim_set_hl(0, "Notify" .. level .. "Border", { italic = false })
			end
		end,
	},
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")
			dashboard.section.header.val = {
				" ",
				"  ██████╗ ███████╗██████╗ ██╗  ██╗  ",
				"  ██╔══██╗██╔════╝██╔══██╗██║ ██╔╝  ",
				"  ██████╔╝███████╗██║  ██║█████╔╝   ",
				"  ██╔═══╝ ╚════██║██║  ██║██╔═██╗   ",
				"  ██║     ███████║██████╔╝██║  ██╗  ",
				"  ╚═╝     ╚══════╝╚═════╝ ╚═╝  ╚═╝  ",
				" ",
				"     ██╗ ██████╗  ██████╗ ███╗   ██╗",
				"     ██║██╔═══██╗██╔═══██╗████╗  ██║",
				"     ██║██║   ██║██║   ██║██╔██╗ ██║",
				"██   ██║██║   ██║██║   ██║██║╚██╗██║",
				"╚█████╔╝╚██████╔╝╚██████╔╝██║ ╚████║",
				" ╚════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝",
				" ",
			}
			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find File", function()
					require("telescope.builtin").find_files({ cwd = os.getenv("HOME"), hidden = false })
				end),
				dashboard.button("h", "  Find File(Hidden)", function()
					require("telescope.builtin").find_files({ cwd = os.getenv("HOME"), hidden = true })
				end),
				dashboard.button("r", "  Recent Files", function()
					require("telescope.builtin").oldfiles()
				end),
				dashboard.button("c", "  Old Commits", function()
					require("telescope.builtin").git_bcommits()
				end),
				dashboard.button("g", "  Git Status", function()
					require("telescope.builtin").git_status()
				end),
			}
			dashboard.section.header.opts.hl = "AlphaHeader"
			dashboard.section.buttons.opts.hl = "AlphaButtons"
			dashboard.section.footer.opts.hl = "AlphaFooter"
			alpha.setup(dashboard.opts)
		end,
	},
}
