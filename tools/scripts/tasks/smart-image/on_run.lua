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
-- @file        on_run.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-06     xqyjlj       initial version
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

    os.vrunv(make_ext4fs_exec, {"-l", size, output, rootfs})
end

function make_fat(size, output, rootfs)
    local target
    local rootfs_dir
    local fatdisk_exec
    local fatdisk_dir = path.absolute("../../../fatdisk", os.scriptdir())

    if os.host() == "windows" then
        fatdisk_exec = path.join(fatdisk_dir, "fatdisk.exe")
    elseif os.host() == "linux" then
        if os.is_arch("x86_64", "x86", "x64") then
            fatdisk_exec = path.join(fatdisk_dir, "fatdisk-x86")
        else
            os.raise("not support arch '%s'", os.arch())
        end
    else
        os.raise("not support host '%s'", os.host())
    end

    os.vrunv(fatdisk_exec, {"--disk_size=" .. size, "--output=" .. output, "--input=" .. rootfs})
end

function make_cromfs(output, rootfs)
    local target
    local rootfs_dir
    local cromfs_exec
    local cromfs_dir = path.absolute("../../../cromfs", os.scriptdir())

    if os.host() == "windows" then
        cromfs_exec = path.join(cromfs_dir, "cromfs-tool.exe")
    elseif os.host() == "linux" then
        if os.is_arch("x86_64", "x86", "x64") then
            cromfs_exec = path.join(cromfs_dir, "cromfs-tool-x86")
        else
            os.raise("not support arch '%s'", os.arch())
        end
    else
        os.raise("not support host '%s'", os.host())
    end

    os.vrunv(cromfs_exec, {rootfs, output})
end

function main()
    config.load()
    -- project.load_targets()

    local format = option.get("format")

    local size = option.get("size")
    local output = option.get("output")
    local rootfs = option.get("rootfs")

    if rootfs then
        if not path.is_absolute(rootfs) then
            rootfs = path.join(os.projectdir(), rootfs)
        end
    else
        rootfs = rt_utils.rootfs_dir()
    end

    if output then
        if not path.is_absolute(output) then
            output = path.join(os.projectdir(), output)
        end
    else
        output = path.join(os.projectdir(), config.buildir(), format .. ".img")
    end

    if format == "ext4" then
        make_ext4(size, output, rootfs)
    elseif format == "fat" then
        make_fat(size, output, rootfs)
    elseif format == "cromfs" then
        make_cromfs(output, rootfs)
    else
        os.raise("unsupport format '%s'", format)
    end

    if os.isfile(output) then
        cprint("${dim}> create %s to %s", rootfs, output)
        cprint('${green}> success create %s image${clear}', format)
    else
        cprint('${red}> fail create ext4 image${clear}')
    end
end
