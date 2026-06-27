-- lua/plugins/tools/dap.lua
-- Debug Adapter Protocol 配置
-- 插件：nvim-dap（核心）+ nvim-dap-ui（界面）+ nvim-dap-virtual-text（行内变量）

return {
  -- DAP 核心
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "williamboman/mason.nvim",
    },
    keys = {
      { "<F9>",       function() require("dap").toggle_breakpoint() end,                        desc = "DAP: 切换断点" },
      { "<F10>",      function() require("dap").step_over() end,                                 desc = "DAP: 单步跳过" },
      { "<F11>",      function() require("dap").step_into() end,                                 desc = "DAP: 单步进入" },
      { "<S-F11>",    function() require("dap").step_out() end,                                  desc = "DAP: 单步跳出" },
      { "<leader>dc", function() require("dap").continue() end,                                  desc = "DAP: 继续" },
      { "<leader>dr", function() require("dap").repl.toggle() end,                               desc = "DAP: REPL" },
      { "<leader>du", function() require("dapui").toggle() end,                                  desc = "DAP: 切换 UI" },
      { "<leader>dh", function() require("dap.ui.widgets").hover() end,                          desc = "DAP: 查看变量" },
    },
    config = function()
      local dap = require("dap")

      -- ==========================================
      -- Python (debugpy)
      -- ==========================================
      dap.adapters.python = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            local userenv = require("config.userenv")
            return userenv.get_python(userenv.conda_env)
          end,
        },
      }

      -- ==========================================
      -- C/C++ (codelldb via Mason)
      -- ==========================================
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/codelldb",
          args = { "--port", "${port}" },
        },
      }
      dap.configurations.c = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.cpp = dap.configurations.c

      -- ==========================================
      -- Java (JDTLS 内置 DAP 支持)
      -- ==========================================
      dap.configurations.java = {
        {
          type = "java",
          request = "launch",
          name = "Launch Java",
          mainClass = function()
            return vim.fn.expand("%:t:r")
          end,
        },
      }

      -- ==========================================
      -- TypeScript/JavaScript (vscode-js-debug via Mason)
      -- ==========================================
      dap.adapters["pwa-node"] = {
        type = "server",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
      dap.configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
      }
      dap.configurations.typescript = dap.configurations.javascript
      dap.configurations.javascriptreact = dap.configurations.javascript
      dap.configurations.typescriptreact = dap.configurations.javascript

      -- ==========================================
      -- Rust (codelldb)
      -- ==========================================
      dap.configurations.rust = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- ==========================================
      -- 符号化 UI
      -- ==========================================
      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticInfo" })
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.40 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks",      size = 0.20 },
              { id = "watches",     size = 0.20 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.70 },
              { id = "console", size = 0.30 },
            },
            size = 0.25,
            position = "bottom",
          },
        },
        floating = {
          border = "rounded",
        },
      })

      -- DAP 启动/停止时自动开关 UI
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        require("dapui").open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        require("dapui").close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        require("dapui").close()
      end
    end,
  },

  -- 行内虚拟文本（变量值显示在代码右侧）
  {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        commented = false,
      })
    end,
  },

  -- Mason 确保调试器已安装（合并到 LazyVim 已有的 Mason 配置）
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "debugpy",
        "codelldb",
        "js-debug-adapter",
      })
    end,
  },
}
