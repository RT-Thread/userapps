local arch = get_config("arch")
if arch == "xuantie" then
    local run_apps = {
        "busybox",
        "cpp",
        "hello",
        "shm_ping",
        "shm_pong",
        "smart-fetch",
        "zlib",
    }
    for _, packagedir in ipairs(run_apps) do
        local packagefile = path.join(path.join(os.scriptdir(), packagedir), "xmake.lua")
        if os.isfile(packagefile) then
            includes(packagefile)
        end
    end
else
    for _, packagedir in ipairs(os.dirs(path.join(os.scriptdir(), "*"))) do
        local packagefile = path.join(packagedir, "xmake.lua")
        if os.isfile(packagefile) then
            includes(packagefile)
        end
    end
end
