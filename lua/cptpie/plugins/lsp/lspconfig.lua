return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Suppress lspconfig deprec warning
		vim.deprecate = function() end
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")

		-- import mason_lspconfig plugin
		local mason_lspconfig = require("mason-lspconfig")

		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap -- for conciseness

		-- Set conceallevel on floating markdown windows (e.g. LSP hover)
		-- Treesitter is disabled for these buffers in treesitter.lua to avoid
		-- a conceal_line decorator crash in nvim-treesitter on 0.12.x
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				local win = vim.api.nvim_get_current_win()
				if vim.api.nvim_win_get_config(win).relative ~= "" then
					vim.api.nvim_set_option_value("conceallevel", 2, { win = win })
				end
			end,
		})

		-- Hover float: not focusable (K / CursorHold auto-hover) and framed with a
		-- thin border. Terminal floats can't have pixel borders; "rounded" is the
		-- single-line box (use "single" for square corners, "double" for a heavy one).
		-- Colour comes from the FloatBorder highlight group.
		local hover_opts = { focusable = false, border = "rounded" }

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", function()
						vim.lsp.buf.hover(hover_opts)
					end, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", "<cmd>lsp restart<CR>", opts) -- mapping to restart lsp if necessary

				-- Enable inlay hints if the language server supports it
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.server_capabilities.inlayHintProvider then
					vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
				end

				-- Auto show hover documentation on CursorHold
				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = ev.buf,
					callback = function()
						vim.lsp.buf.hover(hover_opts)
					end,
				})
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Setup mason lspconfig with default handler
		mason_lspconfig.setup({
			handlers = {
				-- default handler for installed servers
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,
			},
		})

		-- Explicitly configure gopls with inlay hints after mason setup
		lspconfig.gopls.setup({
			capabilities = capabilities,
			settings = {
				gopls = {
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		})

	end,
}
