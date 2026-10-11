return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = {
          prepend_args = function(_, ctx)
            if vim.bo[ctx.buf].filetype:match("^markdown") then
              return {
                "--print-width",
                "80",
                "--prose-wrap",
                "always", -- rewrap paragraphs to the width
                "--config-precedence",
                "prefer-file", -- a project's .prettierrc still wins
              }
            end
            return {}
          end,
        },
      },
    },
  },
}
