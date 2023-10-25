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
-- @file        rtflags.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-09     xqyjlj       initial version
--
import("rt.rt_utils")
import("core.project.config")

function get_real_toolchains(toolchains)
    toolchains = string.gsub(toolchains, "@", "")
    return toolchains
end

function get_real_arch(toolchains)
    local arch = config.arch()
    if arch == "arm64" then
        arch = "aarch64"
    end
    return arch
end

function get_ldscripts(shared)
    if config.get("target_os") ~= "rt-smart" then
        return {ldflags = {}}
    end

    local ldflags = {}

    if not shared then
        table.insert(ldflags, "--static")
    end

    return {ldflags = ldflags}
end

function get_sdk()
    if config.get("target_os") ~= "rt-smart" then
        return {ldflags = {}, ldflags_lib = {}, cxflags = {}}
    end

    local sdkdir = rt_utils.sdk_dir()
    local arch = get_real_arch()
    local rtdir = path.join(sdkdir, "rt-thread")
    local incdir = path.join(sdkdir, "include")
    local libdir = path.join(sdkdir, "lib")
    local cxflags = {}
    local ldflags_lib = {}
    local ldflags = {}

    if arch == "arm" then
        arch = "arm/cortex-a"
    elseif arch == "aarch64" then
        arch = "aarch64/cortex-a"
    elseif arch == "riscv64gc" then
        arch = "risc-v/rv64gc"
    elseif arch == "riscv64gcv" then
        arch = "risc-v/rv64gcv"
    end

    table.insert(cxflags, "-DHAVE_CCONFIG_H")

    if os.isdir(incdir) then
        table.insert(cxflags, "-I" .. incdir)
    end
    table.insert(cxflags, "-I" .. path.join(rtdir, "include"))
    table.insert(cxflags, "-I" .. path.join(rtdir, "components", "dfs"))
    table.insert(cxflags, "-I" .. path.join(rtdir, "components", "drivers"))
    table.insert(cxflags, "-I" .. path.join(rtdir, "components", "finsh"))
    table.insert(cxflags, "-I" .. path.join(rtdir, "components", "net"))

    if os.isdir(libdir) then
        table.insert(ldflags, "-L" .. libdir)
        table.insert(ldflags, "-L" .. path.join(libdir, arch))
    end
    table.insert(ldflags_lib, "-L" .. libdir)
    table.insert(ldflags_lib, "-L" .. path.join(libdir, arch))

    table.insert(ldflags, "-L" .. path.join(rtdir, "lib", arch))
    table.insert(ldflags, "-Wl,--start-group")
    table.insert(ldflags, "-Wl,-whole-archive")
    table.insert(ldflags, "-lrtthread")
    table.insert(ldflags, "-Wl,-no-whole-archive")
    table.insert(ldflags, "-Wl,--end-group")

    return {ldflags = ldflags, ldflags_lib = ldflags_lib, cxflags = cxflags}
end

function get_package_info(package)
    local rtn = {}

    rtn.toolchains = get_real_toolchains(package:configs().toolchains)
    rtn.version = package:version_str()
    rtn.cc, _ = package:tool("cc")
    rtn.cxx, _ = package:tool("cxx")
    rtn.arch = get_real_arch()
    rtn.toolchainsdir = path.directory(rtn.cc)
    rtn.host = string.gsub(path.basename(rtn.cc), "smart", "linux") -- TODO: should replace, when toolchains renamed
    rtn.host = string.gsub(rtn.host, "-gcc", "")

    if rtn.arch == "aarch64" then
        rtn.cpu = "armv8-a"
    elseif rtn.arch == "arm" then
        rtn.cpu = "armv7-a"
    elseif rtn.arch == "x86_64" then
        rtn.cpu = "generic64"
    else
        rtn.cpu = ""
    end

    vprint(rtn)

    return rtn
end

function get_target_info(target)
    local rtn = {}

    rtn.toolchains = get_real_toolchains(target:get("toolchains"))
    rtn.host = rtn.toolchains
    if config.get("target_os") == "rt-smart" then
        if string.startswith(rtn.toolchains, "riscv64") then
            rtn.host = "riscv64-unknown-smart-musl"
        end
    end
    rtn.host = string.gsub(rtn.host, "smart", "linux") -- TODO: should replace, when toolchains renamed
    rtn.cc, _ = target:tool("cc")
    rtn.cxx, _ = target:tool("cxx")
    rtn.arch = get_real_arch()
    rtn.toolchainsdir = path.directory(rtn.cc)

    if rtn.arch == "aarch64" then
        rtn.cpu = "armv8-a"
    end

    local instance = target:toolchain(rtn.toolchains)
    rtn.cxflags = instance:get("cxflags") or {}
    rtn.ldflags = instance:get("ldflags") or {}

    if type(rtn.cxflags) == "string" then
        rtn.cxflags = {rtn.cxflags}
    end
    if type(rtn.ldflags) == "string" then
        rtn.ldflags = {rtn.ldflags}
    end

    vprint(rtn)

    return rtn
end

