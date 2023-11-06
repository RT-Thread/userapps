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
-- @file        x86_64-linux-musleabi.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-18     xqyjlj       initial version
--
toolchain("x86_64-linux-musl") -- add toolchain
do
    set_kind("cross") -- set toolchain kind
    set_description("x86_64 cross compiler for linux.")
    on_load(function(toolchain)
        toolchain:load_cross_toolchain()

        toolchain:set("toolset", "cxx", "x86_64-linux-musl-g++")

        local link_type = os.getenv("RT_XMAKE_LINK_TYPE") or "shared"
        if link_type == "static" then
            toolchain:add("ldflags", "--static", {force = true})
        else
            toolchain:add("ldflags", string.format("-Wl,-rpath=%s/x86_64-linux-musl/lib", toolchain:sdkdir()),
                          {force = true})
        end
    end)
end
toolchain_end()
