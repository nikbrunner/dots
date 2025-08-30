-- Profiler setup (must be first!)
if vim.env.PROF then
  -- Load snacks from opt directory
  vim.cmd("packadd snacks.nvim")
  require("snacks.profiler").startup({
    startup = {
      event = "VimEnter", -- stop profiler on this event
    },
  })
end

require("options")
require("keymaps")
require("auto")
require("lsp_config")
