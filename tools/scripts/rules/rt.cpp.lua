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
-- @author      xqyjlj
-- @file        rt.cpp.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-06-12     xqyjlj       initial version
--
rule("rt.cpp")
do
    on_config(function(target)
        import("core.project.config")
        import("rt.private.build.rtflags")

        local flags = rtflags.get_sdk()

        if config.get("target_os") ~= "rt-smart" then
            return
        end

        target:add("ldflags", flags.ldflags_lib, {force = true})
        target:add("ldflags", "-lcxx", {force = true})

        if config.arch() == "riscv64gc" then
            target:add("ldflags", "-latomic", {force = true})
        end
    end)
end
rule_end()
