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
-- @file        rt.map.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-03-10     xqyjlj       initial version
--
set_xmakever("2.7.2")

rule("rt.map")
do
    on_config(function(target)
        import("core.project.config")
        local artifact_dir = path.join(config.buildir(), config.plat(), config.arch(), config.mode())
        local map = path.join(artifact_dir, target:name() .. ".map")

        target:add("ldflags", "-Wl,-Map," .. map, {force = true})
    end)
end
rule_end()
