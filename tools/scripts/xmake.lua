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
-- Copyright (C) 2022-2023 RT-Thread Development Team
--
-- @author      zhouquan
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-02-28     zhouquan     initial version
--
set_xmakever("2.7.2")

local dir = ""
local rcfiles = os.getenv("XMAKE_RCFILES")
local private_repo = os.getenv("RT_XMAKE_PRIVATEREPO_DIR")
local user_repo = os.getenv("RT_XMAKE_USERREPO_DIR")
if rcfiles then
    dir = path.directory(rcfiles) .. "/"
end

includes(dir .. "modules.lua")
includes(dir .. "rules.lua")
includes(dir .. "tasks.lua")
includes(dir .. "toolchains.lua")

if user_repo then
    add_repositories("rt-smart-user-repo " .. user_repo)
end
if private_repo then
    add_repositories("rt-smart-private-repo " .. private_repo)
end
add_repositories("rt-smart-repo " .. dir .. "../../repo")

local archs = {
    aarch64 = "aarch64-smart-musleabi",
    arm = "arm-smart-musleabi",
    riscv64gc = "riscv64gc-unknown-smart-musl"
}

if not get_config("target_os") then
    set_config("target_os", "rt-smart")
end

local target_os = get_config("target_os") or "rt-smart"

set_config("plat", "cross")
if target_os == "rt-smart" then
    if not get_config("arch") then
        set_config("arch", "aarch64")
    end

    local arch = get_config("arch")

    if table.contains(table.keys(archs), arch) then
        add_requires(archs[arch])
        set_toolchains("@" .. archs[arch])
    end
elseif target_os == "linux" then
    add_requires("x86_64-linux-musl")
    set_toolchains("@x86_64-linux-musl")
end
