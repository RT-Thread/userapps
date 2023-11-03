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
-- @file        arm-smart-musleabi.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-03-10     xqyjlj       initial version
--
set_xmakever("2.7.2")

toolchain("arm-smart-musleabi") -- add toolchain
do
    set_kind("cross") -- set toolchain kind
    set_description("arm embedded compiler for rt-smart")
    on_load(function(toolchain)
        import("rt.private.build.rtflags")
        toolchain:load_cross_toolchain()

        toolchain:set("toolset", "cxx", "arm-linux-musleabi-g++")

        toolchain:add("cxflags", "-march=armv7-a", "-marm", "-msoft-float", {force = true})

        local link_type = os.getenv("RT_XMAKE_LINK_TYPE") or "shared"
        if link_type == "static" then
            local ldscript = rtflags.get_ldscripts(false)
            toolchain:add("ldflags", ldscript.ldflags, {force = true})
        else
            local ldscript = rtflags.get_ldscripts(true)
            toolchain:add("ldflags", ldscript.ldflags, {force = true})
        end
    end)
end
toolchain_end()
