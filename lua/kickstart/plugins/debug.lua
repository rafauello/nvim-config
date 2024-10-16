-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- Ensure that nvim-dap is installed only once
  'mfussenegger/nvim-dap',

  dependencies = {
    'rcarriga/nvim-dap-ui', -- UI interface for nvim-dap
    'thehamsta/nvim-dap-virtual-text', -- Optional: for virtual text display
    'nvim-telescope/telescope-dap.nvim', -- Optional: integration with telescope
    'nvim-neotest/nvim-nio', -- Required for nvim-dap-ui
    'williamboman/mason.nvim', -- To manage installations
    'jay-babu/mason-nvim-dap.nvim', -- Auto-install debug adapters
    'leoluz/nvim-dap-go', -- Go adapter
  },

  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Setup Mason for nvim-dap
    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = { 'delve' }, -- Ensure that you have the delve debugger for Go
    }

    -- Dap UI setup
    dapui.setup {
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

    -- Virtual text setup
    require('nvim-dap-virtual-text').setup {
      enabled = false,
    }

    -- DAP Adapters
    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = '/home/lasotar/.local/share/nvim/mason/bin/OpenDebugAD7',
    }

    dap.adapters.go = {
      type = 'server',
      port = 38697,
      executable = {
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:38697' },
      },
    }

    -- C++ debug configurations
    dap.configurations.cpp = {
      {
        name = 'Launch file',
        type = 'cppdbg',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = false, -- Change to false to start without stopping
        setupCommands = {
          {
            text = '-enable-pretty-printing', -- Helps with formatting complex types
            description = 'enable pretty printing',
            ignoreFailures = false,
          },
        },
      },
    }

    dap.configurations.c = dap.configurations.cpp

    -- Go debug configurations
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

    -- Keybindings for DAP
    vim.fn.sign_define('dapbreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
    vim.api.nvim_set_keymap('n', '<F5>', ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<F10>', ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<F11>', ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<F12>', ":lua require'dap'.step_out()<CR>", { noremap = true, silent = true })

    -- Automatically open dap UI
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    -- Configure DAP for Go
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
