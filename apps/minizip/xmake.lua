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
-- @author      wcx1024979076  
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author         Notes
-- ------------   ----------     -----------------------------------------------
-- 2023-07-26     wcx1024979076  initial version
--
add_rules("mode.debug", "mode.release")

add_requires("minizip")

target("minizip")
do
    add_rules("rt.sdk")
    add_files("minizip.c")
    add_packages("minizip")
end
target_end()

target("miniunz")
do
    add_rules("rt.sdk")
    add_files("miniunz.c")
    add_packages("minizip")
end
target_end()

target("minizip_test")
do
    add_rules("rt.sdk")
    add_files("minizip_test.c")
    add_packages("minizip")
end
target_end()
