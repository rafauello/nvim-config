-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  'mfussenegger/nvim-dap',

  dependencies = {
    'rcarriga/nvim-dap-ui',
    'thehamsta/nvim-dap-virtual-text',
    'nvim-telescope/telescope-dap.nvim',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'julianolf/nvim-dap-lldb', -- Make sure this is included
  },

  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Setup Mason for nvim-dap
    require('mason-nvim-dap').setup {
      automatic_installation = true,
      ensure_installed = { 'delve', 'codelldb' }, -- Ensure codelldb is installed
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

    -- Setup nvim-dap-lldb
    require('dap-lldb').setup {
      configurations = {
        -- C lang configurations
        c = {
          {
            name = 'Launch debugger',
            type = 'lldb',
            request = 'launch',
            cwd = '${workspaceFolder}',
            program = function()
              -- Build with debug symbols
              local out = vim.fn.system { 'make', 'debug' }
              -- Check for errors
              if vim.v.shell_error ~= 0 then
                vim.notify(out, vim.log.levels.ERROR)
                return nil
              end
              -- Return path to the debuggable program
              return 'path/to/executable'
            end,
          },
        },
      },
    }
    dap.set_log_level 'DEBUG'

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
    vim.api.nvim_set_keymap('n', '<leader>bc', ':lua require("dap").toggle_breakpoint()<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>bC', ':lua require("dap").set_breakpoint(vim.fn.input("Condition: "))<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>b<BS>', ':lua require("dap").terminate()<CR>', { noremap = true, silent = true })

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
