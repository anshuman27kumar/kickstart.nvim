return {
  'Vigemus/iron.nvim',
  config = function()
    require('iron.core').setup {
      config = {
        -- Whether a repl should be discarded or not
        scratch_repl = true,
        -- Your repl definitions come here
        repl_definition = {
          sh = {
            -- Can be a table or a function that
            -- returns a table (see below)
            command = { 'zsh' },
          },
          rust = {
            command = { 'evcxr' },
          },
        },
        -- How the repl window will be displayed
        -- See below for more information
        repl_open_cmd = require('iron.view').split.vertical.botright(50),
      },
      -- Iron doesn't set keymaps by default anymore.
      -- You can set them here or manually add keymaps to the functions in iron.core
      keymaps = {
        send_motion = '<Space>sv',
        visual_send = '<Space>sv',
        -- send_file = '<Space>sf',
        send_line = '<Space>sl',
        send_until_cursor = '<Space>su',
        send_mark = '<Space>sm',
        mark_motion = '<Space>mc',
        mark_visual = '<Space>mc',
        remove_mark = '<Space>md',
        cr = '<Space>cr',
        interrupt = '<Space>in',
        exit = '<Space>sq',
        clear = '<Space>cl',
      },
      -- If the highlight is on, you can change how it looks
      -- For the available options, check nvim_set_hl
      highlight = {
        italic = true,
      },
      ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
    }
  end,
}
