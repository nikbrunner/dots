local M = {}

function M:write(path, tbl)
    local ok, _ = pcall(function()
        local fd = assert(vim.uv.fs_open(path, "w", 438)) -- 438 = 0666
        assert(vim.uv.fs_write(fd, vim.json.encode(tbl)))
        assert(vim.uv.fs_close(fd))
    end)

    return ok
end

function M:read(path)
    local ok, content = pcall(function()
        local fd = assert(vim.uv.fs_open(path, "r", 438)) -- 438 = 0666
        local stat = assert(vim.uv.fs_fstat(fd))
        local data = assert(vim.uv.fs_read(fd, stat.size, 0))
        assert(vim.uv.fs_close(fd))
        return data
    end)

    return ok and vim.json.decode(content) or nil
end

return M
