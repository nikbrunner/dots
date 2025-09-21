WhichKeyIgnoreLabel = "which_key_ignore"

vim.g.mapleader = ","
vim.g.maplocalleader = "."

vim.opt.mouse = "a"

vim.opt.clipboard = "unnamedplus"

vim.opt.spelllang = "en_us,de_de"

vim.opt.cursorline = true
vim.opt.cursorcolumn = false

-- preview for substitution
vim.opt.inccommand = "split"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
-- vim.opt.autoindent = true

vim.o.winborder = "solid"

vim.o.conceallevel = 0

vim.opt.jumpoptions = "stack"

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "indent"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.opt.foldcolumn = "0"
vim.opt.fillchars:append({ fold = " " })

vim.opt.wildmode = "longest:full,full"

vim.opt.jumpoptions = "stack"

vim.opt.fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
}

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autoread = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.updatetime = 500

vim.opt.cmdheight = 0
vim.opt.pumheight = 30
vim.opt.pumblend = 10

vim.opt.winbar = "%f"

vim.opt.showmode = false
vim.opt.laststatus = 3

vim.opt.wrap = false

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.termguicolors = true

vim.opt.guifont = { "JetBrainsMono Nerd Font", ":h16" }

vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.scrolloff = 4

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.splitbelow = true
vim.opt.splitright = true

-- Abbreviations
vim.cmd("cabbrev Wqa wqa")
vim.cmd("cabbrev Wq wq")
vim.cmd("cabbrev Wa wa")

vim.filetype.add({
    http = "http",
    -- I only needed this because barbecue vomits if i vist this file, because it thinks its lua
    filename = {
        [".luacheckrc"] = ".luacheckrc",
    },
})

-- For terminals disable numbers and relative numbers
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("term-options", { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.opt.signcolumn = "no"
    end,
})

-- :h vim._extui
require("vim._extui").enable({
    enable = true, -- Whether to enable or disable the UI.
    msg = { -- Options related to the message module.
        ---@type 'cmd'|'msg' Where to place regular messages, either in the
        ---cmdline or in a separate ephemeral message window.
        target = "cmd",
        timeout = 4000, -- Time a message is visible in the message window.
    },
})

function _G.my_tabline()
    local current_tab = vim.fn.tabpagenr()
    local current_win = vim.fn.tabpagewinnr(current_tab)
    local parts = { "%#TabLine# " .. current_tab .. ":" .. vim.fn.tabpagenr("$") .. " %#TabLineFill#   " }

    for i, bufnr in ipairs(vim.fn.tabpagebuflist(current_tab)) do
        local bufname = vim.fn.bufname(bufnr)
        local buftype = vim.fn.getbufvar(bufnr, "&buftype")
        local filetype = vim.fn.getbufvar(bufnr, "&filetype")

        -- Only include normal files, unnamed buffers, or help files
        if buftype == "" or filetype == "help" then
            -- Highlight and separator
            local hl = i == current_win and "%#TabLineSel#" or "%#TabLine#"
            table.insert(parts, " " .. hl .. " ")

            -- Get filename
            local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:.") or "[No Name]"
            if bufname ~= "" and string.match(filename, "^/") then
                filename = vim.fn.fnamemodify(bufname, ":t")
            end

            -- Add modified indicator
            local modified = vim.fn.getbufvar(bufnr, "&modified") == 1 and "●" or ""
            table.insert(parts, filename .. modified .. " ")
        end
    end

    return table.concat(parts) .. "%#TabLineFill#"
end

vim.o.tabline = "%!v:lua.my_tabline()"
