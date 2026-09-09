return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    -- Patch nvim-treesitter's set-lang-from-info-string! directive to guard
    -- against nil nodes inside get_node_text. Fixes a conceal_line crash on
    -- Neovim 0.12.x when hovering over LSP symbols (markdown float).
    local ok, ts_query = pcall(require, "vim.treesitter.query")
    if ok and ts_query and ts_query.add_directive then
      ts_query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
        local capture_id = pred[2]
        local node = match[capture_id]
        if not node then
          return
        end
        local success, text = pcall(vim.treesitter.get_node_text, node, bufnr)
        if not success or not text then
          return
        end
        metadata["injection.language"] = text:lower()
      end, { force = true, all = true })
    end

    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      -- ensure these language parsers are installed
      ensure_installed = {
        "json",
        "javascript",
        "yaml",
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "vimdoc",
        "c",
        "go",
        "bibtex",
        "cpp",
        "gomod",
        "haskell",
        "latex"
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
