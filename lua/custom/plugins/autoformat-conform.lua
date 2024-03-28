return {

  'stevearc/conform.nvim',

  event = { 'BufWritePre', 'BufReadPre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  -- Everything in opts will be passed to setup()
  opts = {

    -- Map of filetype to formatters
    formatters_by_ft = {
      lua = { 'stylua' },
      rust = { 'rustfmt' },
      -- Conform will run multiple formatters sequentially
      -- Use a sub-list to run only the first available formatter
      javascript = { { 'prettierd', 'prettier' } },
      -- You can use a function here to determine the formatters dynamically
      python = function(bufnr)
        if require('conform').get_formatter_info('ruff_format', bufnr).available then
          return { 'ruff_format' }
        else
          return { 'isort', 'black' }
        end
      end,
    },
    -- If this is set, Conform will run the formatter on save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true, lua = false, python = false, r = false }
      return {
        timeout_ms = 500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,

    -- Set the log level. Use `:ConformInfo` to see the location of the log file.
    log_level = vim.log.levels.DEBUG,
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
}
