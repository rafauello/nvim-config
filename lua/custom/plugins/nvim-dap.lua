return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui', -- optional: for a ui interface
      'thehamsta/nvim-dap-virtual-text', -- optional: for virtual text display
      'nvim-telescope/telescope-dap.nvim', -- optional: integration with telescope
    },
    config = function()
      require('dapui').setup()
      require('nvim-dap-virtual-text').setup()

      local dap = require 'dap'
      local dapui = require 'dapui'

      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = '/home/lasotar/.local/share/nvim/mason/bin/OpenDebugAD7',
      }

      -- C++ debug adapter configuration
      dap.configurations.cpp = {
        {
          name = 'Launch file',
          type = 'cppdbg',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = true,
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'cppdbg',
          request = 'launch',
          MIMode = 'gdb',
          miDebuggerServerAddress = 'localhost:1234',
          miDebuggerPath = '/usr/bin/gdb',
          cwd = '${workspaceFolder}',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
        },
      }

      -- GO debug adapter configuration
      dap.adapters.go = {
        type = 'server',
        port = 38697,
        executable = {
          command = 'dlv',
          args = { 'dap', '-l', '127.0.0.1:38697' },
        },
      }

      dap.configurations.go = {
        {
          type = 'go',
          name = 'Debug',
          request = 'launch',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'go',
          name = 'Debug (Attach)',
          request = 'attach',
          mode = 'remote',
          port = 38697,
        },
      }

      -- keybindings for dap
      vim.fn.sign_define('dapbreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
      vim.api.nvim_set_keymap('n', '<f5>', ":lua require'dap'.continue()<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<f10>', ":lua require'dap'.step_over()<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<f11>', ":lua require'dap'.step_into()<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<f12>', ":lua require'dap'.step_out()<cr>", { noremap = true, silent = true })

      -- automatically open dap ui
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },
}
