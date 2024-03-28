-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Manages various debugger plugins
    'Pocco81/DAPInstall.nvim',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local dapuiw = require 'dap.ui.widgets'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    --vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    --vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    --vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' }) ]]
    vim.keymap.set('n', '<leader>tb', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })
    vim.keymap.set('n', '<leader>dr', dap.run_to_cursor, { desc = 'Debug: Run to Cursor' })
    vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug UI: Toggle UI' })
    vim.keymap.set('n', '<leader>db', dap.step_back, { desc = 'Debug: Step back' })
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
    vim.keymap.set('n', '<leader>de', dapui.eval, { desc = 'Debug UI: Evaluate' })
    vim.keymap.set('n', '<leader>dg', dap.session, { desc = 'Debug: Get Session' })
    vim.keymap.set('n', '<leader>dh', dapuiw.hover, { desc = 'Debug: Hover Variables' })
    -- vim.keymap.set('n', '<leader>ds', dapuiw.scopes, { desc = 'Debug: Scopes' })
    vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step into' })
    vim.keymap.set('n', '<leader>dv', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<leader>do', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>dp', dap.pause, { desc = 'Debug: Pause' })
    vim.keymap.set('n', '<leader>tr', dap.repl.toggle, { desc = 'Debug: Toggle REPL' })
    vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Debug: Terminate' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Python specific config
    dap.adapters.python = {
      type = 'executable',
      command = 'python',
      args = { '-m', 'debugpy.adapter' },
    }
    dap.configurations.python = {
      {
        justMyCode = false,
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        args = get_args,
        pythonPath = function()
          local venv_path = os.getenv 'VIRTUAL_ENV'
          if venv_path then
            return venv_path .. '/bin/python'
          end
          return '/Users/anskumar/anaconda3/bin/python'
        end,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Debug Tests',
        module = 'pytest',
        args = { 'tests' },
      },
    }

    -- Golang specific config
    require('dap-go').setup()

    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = 'codelldb',
        args = { '--port', '${port}' },

        -- On windows you may have to uncomment this:
        -- detached = false,
      },
    }

    -- Rust specific config
    dap.configurations.rust = {
      {
        name = 'Launch Rust',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        terminal = 'integrated',
        sourceLanguages = { 'rust' },
      },
    }

    --require('dap-python').setup '/Users/anskumar/anaconda3/bin/python'
  end,
}
