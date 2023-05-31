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
-- @author      zhouquan
-- @file        on_run.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-06     zhouquan     initial version
--
import("core.project.project")
import("core.project.config")
import("core.base.option")
import("rt.rt_utils")

function make_ext4(size, output, rootfs)
    local target
    local rootfs_dir
    local make_ext4fs_exec
    local make_ext4fs_dir = path.absolute("../../../make_ext4fs", os.scriptdir())

    if not os.host() == "linux" then
        os.raise("not support host '%s'", os.host())
    end

    if os.arch() == "x86_64" then
        make_ext4fs_exec = path.join(make_ext4fs_dir, "make_ext4fs-x86")
    else
        os.raise("not support arch '%s'", os.arch())
    end

    if rootfs then
        if path.is_absolute(rootfs) then
            rootfs_dir = rootfs
        else
            rootfs_dir = path.join(os.projectdir(), rootfs)
        end
    else
        rootfs_dir = rt_utils.rootfs_dir()
    end

    if path.is_absolute(output) then
        target = output
    else
        target = path.join(os.projectdir(), output)
    end

    os.execv(make_ext4fs_exec, {"-l", size, target, rootfs_dir})

    if os.isfile(target) then
        cprint("${dim}> create %s to %s", rootfs_dir, target)
        cprint('${green}> success create ext4 image${clear}')
    else
        cprint('${red}> fail create ext4 image${clear}')
    end
end

function main()
    config.load()
    -- project.load_targets()

    local format = option.get("format")
    if format == "ext4" then
        make_ext4(option.get("size"), option.get("output"), option.get("rootfs"))
    else
        os.raise("unsupport format '%s'", format)
    end
end
