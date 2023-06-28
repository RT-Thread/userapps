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
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-03-10     xqyjlj       initial version
--
add_rules("mode.debug", "mode.release")

target("webserver")
do
    add_includedirs("./", "./packages/webnet-v2.0.2/inc")
    add_rules("rt.sdk")
    add_defines("closesocket=close", "HAVE_PKG_CONFIG_H")
    add_files("*.c")
    add_files("./packages/webnet-v2.0.2/src/*.c")
    add_files("./packages/webnet-v2.0.2/samples/*.c")
    add_files("./packages/webnet-v2.0.2/module/*.c")
end
target_end()
