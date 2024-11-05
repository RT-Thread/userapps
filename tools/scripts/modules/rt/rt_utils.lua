-- Licensed under the Apache License, Version 2.0 (the "License");
-- You may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2023-2023 RT-Thread Development Team
--
-- @author      xqyjlj  
-- @file        rt_utils.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-09     xqyjlj       initial version
--
import("core.project.project")
import("core.project.config")

function rootfs_dir()
    local rootdir
    local userapps_dir = os.getenv("RT_XMAKE_USERAPPS_DIR")

    if userapps_dir then
        rootdir = path.join(userapps_dir, "rootfs")
    else
        rootdir = path.join(project.directory(), config.buildir(), "rootfs") -- use default rootfs
    end

    if not os.exists(rootdir) then
        os.mkdir(rootdir)
    end

    return rootdir
end

function ldscripts_dir()
    local rootdir
    local userapps_dir = os.getenv("RT_XMAKE_USERAPPS_DIR")
    if userapps_dir then
        rootdir = path.join(userapps_dir, "linker_scripts")
    else
        rootdir = path.absolute("../../../ldscripts", os.scriptdir()) -- use default ldscripts
    end

    return rootdir
end

function sdk_dir()
    local rootdir
    local userapps_dir = os.getenv("RT_XMAKE_USERAPPS_DIR")

    if userapps_dir then
        rootdir = path.join(userapps_dir, "sdk")
    else
        rootdir = path.absolute("../../../../sdk", os.scriptdir()) -- use default prebuilt sdk
    end

    return rootdir
end

function cp_with_symlink(srcpath, dstpath, opt)
    local option

    if (os.getenv("--rt-xmake-no-symlink") == "true") then
        option = opt or {symlink = false}
    else
        option = opt or {symlink = true}
    end
    os.tryrm(dstpath)
    os.vcp(srcpath, dstpath, option)
end

function dirsize(dir)
    if not os.isdir(dir) then
        raise('not find dir "%s"', dir)
    end

    if os.host() == "linux" then
        local result = os.iorunv("du", {"-sh", dir})
        local size = result:match("^(%S+)%s+")
        return size
    else
        return "unknown"
    end
end
