local M = {}

---@type vim.pack.Spec
M.spec = {
    src = "https://github.com/mason-org/mason.nvim",
}

-- Direct Mason package names
-- https://mason-registry.dev/registry/list
M.packages = {
    -- LSP Servers
    "astro-language-server",
    "bash-language-server",
    "css-lsp",
    "gopls",
    "html-lsp",
    "json-lsp",
    "lua-language-server",
    "marksman",
    "tailwindcss-language-server",
    "vtsls",
    "yaml-language-server",

    -- Tools
    "stylua",
    "luacheck",
    "shellcheck",
    "prettierd",
    "shfmt",
}

function M:setup_install_notification()
    vim.api.nvim_create_autocmd("User", {
        pattern = "MasonToolsStartingInstall",
        callback = function()
            vim.schedule(function()
                vim.notify("Mason: Installing configured packages...", vim.log.levels.INFO)
            end)
        end,
    })
end

function M:install_package(pkg, pkg_name)
    vim.notify(string.format("Mason: Installing %s", pkg_name), vim.log.levels.INFO)

    pkg:install({}, function(success, result)
        vim.schedule(function()
            if success then
                vim.notify(string.format("Mason: Successfully installed %s", pkg_name), vim.log.levels.INFO)
            else
                vim.notify(
                    string.format("Mason: Failed to install %s: %s", pkg_name, tostring(result)),
                    vim.log.levels.ERROR
                )
            end
        end)
    end)
end

function M:get_missing_packages(registry)
    local missing = {}

    for _, pkg_name in ipairs(M.packages) do
        local ok, pkg = pcall(registry.get_package, pkg_name)
        if ok then
            if not pkg:is_installed() then
                table.insert(missing, { name = pkg_name, package = pkg })
            end
        else
            vim.notify(string.format("Mason: Package '%s' not found in registry", pkg_name), vim.log.levels.WARN)
        end
    end

    return missing
end
function M:ensure_installed()
    local registry = require("mason-registry")

    registry.refresh(function()
        local missing_packages = M:get_missing_packages(registry)

        if #missing_packages > 0 then
            vim.api.nvim_exec_autocmds("User", { pattern = "MasonToolsStartingInstall" })

            for _, pkg_info in ipairs(missing_packages) do
                M:install_package(pkg_info.package, pkg_info.name)
            end
        end
    end)
end

function M.init()
    local present, mason = pcall(require, "mason")

    if not present then
        vim.notify_once("`Mason` module not found!", vim.log.levels.ERROR)
        return
    end

    mason.setup()

    -- Custom ensure_installed implementation
    -- Based on: https://github.com/mason-org/mason.nvim/pull/1949
    M:setup_install_notification()

    -- Run ensure_installed after a small delay to ensure mason is fully loaded
    vim.defer_fn(function()
        M:ensure_installed()
    end, 100)
end

return M
