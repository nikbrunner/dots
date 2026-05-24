-- inspiration: https://github.com/diogo464/hotreload.nvim
local M = {}

local function should_check()
    local mode = vim.api.nvim_get_mode().mode
    return not (
        mode:match("[cR!s]") -- Skip: command-line, replace, ex, select modes
        or vim.fn.getcmdwintype() ~= "" -- Skip: command-line window is open
    )
end

M.setup = function(opts)
    vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave", "BufEnter", "WinEnter", "CursorHold", "CursorHoldI" }, {
        group = vim.api.nvim_create_augroup("hotreload", { clear = true }),
        callback = function()
            if should_check() then
                vim.cmd("checktime")
            end
        end,
    })
end

return M
