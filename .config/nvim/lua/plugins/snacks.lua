return{
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = true },
        animate = { enabled = true},
        dashboard = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        lazygit = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
            terminal = {
                bo = {
                    filetype = "snacks_terminal",
                },
                wo = {
                    winhighlight = "Normal:TerminalWindow",
                },
            }
        },
        terminal = { 
            enabled = true,
            win = {
                style = "terminal",
            },
            auto_insert = false,
        },
        zen =  { enabled = True },
        gitbrowse = {
            enabled = true,
            notify = true,
            what = "file",
            open = function(url)
                if vim.fn.has("nvim-0.10") == 0 then
                    require("lazy.util").open(url, { system = true })
                    return
                end
                vim.ui.open(url)
            end,
            remote_patterns = {
                { "^(https?://.*)%.git$", "%1" },
                { "^git@(.+):(.+)%.git$", "https://%1/%2" },
                { "^git@(.+):(.+)$", "https://%1/%2" },
                { "^git@(.+)/(.+)$", "https://%1/%2" },
                { "^ssh://git@(.*)$", "https://%1" },
                { "^ssh://([^:/]+)(:%d+)/(.*)$", "https://%1/%3" },
                { "^ssh://([^/]+)/(.*)$", "https://%1/%2" },
                { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
                { "^https://%w*@(.*)", "https://%1" },
                { "^git@(.*)", "https://%1" },
                { ":%d+", "" },
                { "%.git$", "" },
            },
            url_patterns = {
                ["github%.com"] = {
                    branch = "/tree/{branch}",
                    file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
                    commit = "/commit/{commit}",
                },
                ["gitlab%.com"] = {
                    branch = "/-/tree/{branch}",
                    file = "/-/blob/{branch}/{file}#L{line_start}-L{line_end}",
                    commit = "/-/commit/{commit}",
                },
                ["bitbucket%.org"] = {
                    branch = "/src/{branch}",
                    file = "/src/{branch}/{file}#lines-{line_start}-L{line_end}",
                    commit = "/commits/{commit}",
                },
            },
        },
    },
    }
}
