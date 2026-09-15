return {
  {
    "rakr/vim-one",
    priority=1000,
    config = function()
      vim.cmd([[colorscheme one]])

      -- Transparent background: let the terminal's own (blurred, translucent)
      -- background show through instead of painting a solid box inside kitty's padding.
      local function clear_bg()
        for _, group in ipairs({
          "Normal", "NormalNC", "NormalFloat", "FloatBorder",
          "SignColumn", "LineNr", "CursorLineNr", "FoldColumn",
          "EndOfBuffer", "NonText", "WinSeparator", "VertSplit",
          "StatusLine", "StatusLineNC", "TabLineFill",
        }) do
          local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
          hl.bg, hl.ctermbg = nil, nil
          vim.api.nvim_set_hl(0, group, hl)
        end
      end
      clear_bg()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_bg })
    end,
  },
}
