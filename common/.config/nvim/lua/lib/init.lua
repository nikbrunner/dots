---@class VinLib
local M = {}

-- Lazy-load modules on access
setmetatable(M, {
    __index = function(t, k)
        local modules = {
            copy = "lib.copy",
            colors = "lib.colors",
            files = "lib.files",
            git = "lib.git",
            ui = "lib.ui",
            config = "lib.config",
            lsp = "lib.lsp",
        }

        if modules[k] then
            local module = require(modules[k])
            rawset(t, k, module)
            return module
        end
    end,
})

return M
