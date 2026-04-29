return {
  {
    "brianhuster/live-preview.nvim",
    cmd = { "LivePreview" },
    keys = {
      {
        "<leader>lp",
        function()
          local lp = require("livepreview")
          local cfg = require("livepreview.config").config
          local utils = require("livepreview.utils")
          local fs = vim.fs

          local filepath = vim.api.nvim_buf_get_name(0)
          if filepath == "" or not utils.supported_filetype(filepath) then
            vim.notify(
              "live-preview.nvim: current buffer is not a supported filetype",
              vim.log.levels.WARN
            )
            return
          end
          filepath = fs.normalize(filepath)

          -- Start the server only on the first invocation; subsequent calls
          -- just navigate the browser tab to the current buffer's URL. The
          -- server serves any file in the project, so a restart is wasteful
          -- and triggers a port-in-use warning while the old TCP socket is
          -- still being torn down.
          if not lp.is_running() then
            lp.start(filepath, cfg.port)
          end

          local urlpath = (cfg.dynamic_root and fs.basename(filepath) or utils.get_relative_path(
            filepath,
            fs.normalize(vim.uv.cwd() or "")
          )):gsub(" ", "%%20")
          local url = ("http://%s:%d/%s"):format(cfg.address, cfg.port, urlpath)
          utils.open_browser(url, cfg.browser)
        end,
        desc = "[L]ive-Preview [P]review (current buffer)",
      },
      { "<leader>lc", "<cmd>LivePreview close<cr>", desc = "[L]ive-Preview [C]lose" },
      { "<leader>lk", "<cmd>LivePreview pick<cr>",  desc = "[L]ive-Preview pic[K] file" },
      { "<leader>lh", "<cmd>LivePreview help<cr>",  desc = "[L]ive-Preview [H]elp" },
    },
  },
}
