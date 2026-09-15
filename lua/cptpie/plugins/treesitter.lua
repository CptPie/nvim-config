-- nvim-treesitter `main` branch (2025 rewrite): no more `configs`/`setup({...})`.
-- Parsers are installed with `install()`, highlighting/indent are enabled per
-- buffer through core Neovim APIs, and autotag configures itself.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- must be on the runtimepath before parsers/queries are needed
  build = ":TSUpdate",
  dependencies = {
    {
      "windwp/nvim-ts-autotag",
      opts = {}, -- standalone since the treesitter rewrite; `opts` calls setup()
    },
  },
  config = function()
    local treesitter = require("nvim-treesitter")

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

    -- ensure these language parsers are installed (async, no-op if present)
    treesitter.install({
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
      "latex",
    })

    -- enable syntax highlighting + indentation for every buffer that has a parser
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("cptpie_treesitter", { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
        if not vim.treesitter.language.add(lang) then
          return
        end
        pcall(vim.treesitter.start, ev.buf, lang)
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- incremental selection (dropped from the plugin): <C-space> grows the
    -- selection to the enclosing node, <BS> shrinks it back.
    local sel_stack = {}
    local function select_node(node)
      local sr, sc, er, ec = node:range()
      vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
      vim.cmd("normal! v")
      vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
    end
    vim.keymap.set({ "n", "x" }, "<C-space>", function()
      local mode = vim.fn.mode()
      local node
      if mode == "n" or #sel_stack == 0 then
        node = vim.treesitter.get_node()
        sel_stack = {}
      else
        node = sel_stack[#sel_stack]:parent()
      end
      if not node then
        return
      end
      -- skip parents with an identical range so every press visibly grows
      local last = sel_stack[#sel_stack]
      while node and last and vim.deep_equal({ node:range() }, { last:range() }) do
        node = node:parent()
      end
      if not node then
        return
      end
      sel_stack[#sel_stack + 1] = node
      select_node(node)
    end, { desc = "Treesitter: expand selection" })
    vim.keymap.set("x", "<BS>", function()
      if #sel_stack <= 1 then
        return
      end
      sel_stack[#sel_stack] = nil
      select_node(sel_stack[#sel_stack])
    end, { desc = "Treesitter: shrink selection" })
  end,
}
