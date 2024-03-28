-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    '3rd/image.nvim',
  },
  vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal left<CR>'),
  --[[   vim.keymap.set('n', 'n', function()
    require('neo-tree.command').execute { action = 'close' }
  end, {}), -- Key mapping for closing Neotree
 ]]
  -- Find with telescope plugin
  config = function()
    local function getTelescopeOpts(state, path)
      return {
        cwd = path,
        search_dirs = { path },
        attach_mappings = function(prompt_bufnr, map)
          local actions = require 'telescope.actions'
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local action_state = require 'telescope.actions.state'
            local selection = action_state.get_selected_entry()
            local filename = selection.filename
            if filename == nil then
              filename = selection[1]
            end
            -- any way to open the file without triggering auto-close event of neo-tree?
            require('neo-tree.sources.filesystem').navigate(state, state.path, filename)
          end)
          return true
        end,
      }
    end
    require('neo-tree').setup {
      close_if_last_window = true,
      -- Autoclose NeoTree when file is opened
      event_handlers = {
        {
          event = 'file_opened',
          handler = function(file_path)
            -- auto close
            vim.cmd 'Neotree close'
          end,
        },
      },
      filesystem = {
        window = {
          mappings = {
            ['tf'] = 'telescope_find',
            ['tg'] = 'telescope_grep',
            --[[             ['g'] = 'git_focus', ]]
            --[[ ['e'] = 'filesystem_focus', ]]
            -- ['<2-LeftMouse>'] = 'open',
            --[[             ['b'] = 'buffer_focus', ]]
          },
        },
        commands = {
          telescope_find = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require('telescope.builtin').find_files(getTelescopeOpts(state, path))
          end,
          telescope_grep = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
          end,
          --[[ git_focus = function(state)
            vim.api.nvim_exec2('Neotree focus git_status left', {})
          end, ]]
          --[[           filesystem_focus = function(state)
            vim.api.nvim_exec2('Neotree focus filesystem left', {})
          end,
          buffer_focus = function(state)
            vim.api.nvim_exec2('Neotree focus buffers left', {})
          end,
  ]]
        },
      },
    }
  end,
}
