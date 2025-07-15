return{
    {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "vhyrro/luarocks.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      --"3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    opts = {
        enable_normal_mode_for_keymaps = true,
        window = {
            mappings = {
                ["<Space>"] = false,
                ["P"] = { "toggle_preview", config = { use_float = false, use_image_nvim = false } },
                ["J"] = function(state)
                  local tree = state.tree
                  local node = tree:get_node()
                  local siblings = tree:get_nodes(node:get_parent_id())
                  local renderer = require('neo-tree.ui.renderer')
                  renderer.focus_node(state, siblings[#siblings]:get_id())
                end,
                ["K"] = function(state)
                  local tree = state.tree
                  local node = tree:get_node()
                  local siblings = tree:get_nodes(node:get_parent_id())
                  local renderer = require('neo-tree.ui.renderer')
                  renderer.focus_node(state, siblings[1]:get_id())
                end,
            }
        }
    },
    },
    {
        's1n7ax/nvim-window-picker',
        name = 'window-picker',
        event = 'VeryLazy',
        version = '2.*',
        config = function()
            require'window-picker'.setup()
        end,
    }
}
