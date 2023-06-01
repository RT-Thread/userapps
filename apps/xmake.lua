for _, packagedir in ipairs(os.dirs(path.join(os.scriptdir(), "*"))) do
    local packagefile = path.join(packagedir, "xmake.lua")
    if os.isfile(packagefile) then
        includes(packagefile)
    end
end
