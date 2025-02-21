return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v2.x",
  dependencies = {
    { "neovim/nvim-lspconfig" },
    {
      "williamboman/mason.nvim",
      config = function()
        pcall(vim.cmd, "MasonUpdate")
      end,
    },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip",                 ft = { "lua" } },
  },
  config = function()
    local lsp = require("lsp-zero")

    lsp.preset("recommended")

    lsp.ensure_installed({ "ts_ls", "eslint" })

    -- navigating completions
    local cmp = require("cmp")
    local cmp_select = {
      behavior = cmp.SelectBehavior.Select,
    }
    local cmp_mappings = lsp.defaults.cmp_mappings({
      ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
      ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
      ["<C-y>"] = cmp.mapping.confirm({
        select = true,
      }),
      ["<C-Space>"] = cmp.mapping.complete(),
    })

    lsp.setup_nvim_cmp({
      mappings = cmp_mappings,

      -- completion = {
      --     autocomplete = {},
      -- }
    })

    -- disables "sign icons"?
    lsp.set_preferences({
      sign_icons = {},
    })

    lsp.on_attach(function(client, bufnr)
      local opts = {
        buffer = bufnr,
        remap = false,
      }

      if client.name == "eslint" then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "EslintFixAll",
        })
      end

      vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
      end, opts)
      vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover()
      end, opts)
      vim.keymap.set("n", "<leader>vws", function()
        vim.lsp.buf.workspace_symbol()
      end, opts)
      vim.keymap.set("n", "<leader>vd", function()
        vim.diagnostic.open_float()
      end, opts)
      vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_next()
      end, opts)
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_prev()
      end, opts)
      vim.keymap.set("n", "<leader>vca", function()
        vim.lsp.buf.code_action()
      end, opts)
      vim.keymap.set("n", "<leader>vrr", function()
        require("telescope.builtin").lsp_references()
      end, opts)
      vim.keymap.set("n", "<leader>vrn", function()
        vim.lsp.buf.rename()
      end, opts)
      vim.keymap.set("i", "<C-h>", function()
        vim.lsp.buf.signature_help()
      end, opts)
      -- keymap to restart lsp since some like to crash
      vim.keymap.set("n", "<leader><leader>r", function()
        vim.cmd("LspRestart")
      end, opts)
    end)

    -- lua ls config
    require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
    require("lspconfig").ts_ls.setup({})

    lsp.setup()
  end,
}
