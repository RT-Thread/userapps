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
-- @file        rt.sdk.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-08     xqyjlj       initial version
--
set_xmakever("2.7.2")

rule("rt.sdk")
do
    on_config(function(target)
        import("rt.private.build.rtflags")
        local flags = rtflags.get_sdk()

        target:add("cxflags", flags.cxflags, {force = true})
        target:add("ldflags", flags.ldflags, {force = true})
    end)
end
rule_end()
