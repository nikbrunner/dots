-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/sourcekit.lua

---@type vim.lsp.Config
return {
    cmd = { "sourcekit-lsp" },
    filetypes = { "swift", "objc", "objcpp", "c", "cpp" },
    root_markers = { "buildServer.json", ".bsp", "*.xcodeproj", "*.xcworkspace", "Package.swift", ".git" },
}
