--- Helpers for Bitbucket Server (Data Center) URL construction
---
--- Handles both personal repos (~username) and project repos.
--- @param org string org component from linker (e.g. "~brunner" or "PROJECT")
--- @return string, string URL prefix and the org/user name
local function bb_server_org_parts(org)
    local user = org:match("^~(.+)$")
    if user then
        return "users", user
    end
    return "projects", org
end

--- Strip .git suffix from repo name.
--- @param repo string
--- @return string
local function bb_server_repo_name(repo)
    return repo:match("^(.*)%.git$") or repo
end

--- Build line range fragment for Bitbucket Server.
--- Uses #{start}-{end} format (bare line numbers, no L prefix).
--- @param lstart integer|nil
--- @param lend integer|nil
--- @return string
local function bb_server_line_range(lstart, lend)
    if not lstart then
        return ""
    end
    local r = string.format("#%d", lstart)
    if lend and lend > lstart then
        r = r .. string.format("-%d", lend)
    end
    return r
end

--- Build a full Bitbucket Server URL.
--- @param lk gitlinker.Linker
--- @param endpoint string "browse" | "annotate"
--- @param ref string rev, default_branch, or current_branch
--- @return string
local function bb_server_url(lk, endpoint, ref)
    local prefix, name = bb_server_org_parts(lk.org)
    local url = string.format(
        "https://%s/%s/%s/repos/%s/%s/%s?at=%s",
        lk.host, prefix, name, bb_server_repo_name(lk.repo),
        endpoint, lk.file, ref
    )
    return url .. bb_server_line_range(lk.lstart, lk.lend)
end

--- @type LazyPluginSpec
return {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    event = "BufEnter",
    keys = {
        {
            mode = { "n", "v" },
            "<leader>dyg",
            "<CMD>GitLink<CR>",
            desc = "[G]it Link",
        },
    },
    opts = {
        router = {
            browse = {
                ["^bitbucket%.imfusion%.com"] = function(lk)
                    return bb_server_url(lk, "browse", lk.rev)
                end,
            },
            blame = {
                ["^bitbucket%.imfusion%.com"] = function(lk)
                    return bb_server_url(lk, "annotate", lk.rev)
                end,
            },
            default_branch = {
                ["^bitbucket%.imfusion%.com"] = function(lk)
                    return bb_server_url(lk, "browse", lk.default_branch or lk.rev)
                end,
            },
            current_branch = {
                ["^bitbucket%.imfusion%.com"] = function(lk)
                    return bb_server_url(lk, "browse", lk.current_branch or lk.rev)
                end,
            },
        },
    },
}
