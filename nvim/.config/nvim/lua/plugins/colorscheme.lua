return {
  {
    "folke/tokyonight.nvim",
    opts = {
      on_highlights = function(hl, c)
        hl.WinSeparator = {
          fg = "#66b2b2",
          bg = "NONE",
        }
        hl.VertSplit = {
          fg = "#66b2b2",
          bg = "NONE",
        }
        hl.VirtColumn = {
          fg = "#ff00ff",
        } -- magenta 80-column line
      end,
    },
  },
}
