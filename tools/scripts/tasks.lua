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
-- @file        tasks.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-06     xqyjlj       initial version
--
set_xmakever("2.7.2")

task("smart-image")
do
    on_run("tasks/smart-image/on_run")
    set_category("plugin")
    set_menu {
        usage = "xmake smart-image [options]",
        description = "make image",
        options = {
            {"f",   "format",           "kv",   "ext4",                                     "image format",
                                                                                            "    - ext4",
                                                                                            "    - fat"},
            {"s",   "size",             "kv",   "256M",                                     "image size"},
            {"o",   "output",           "kv",   nil,                                        "output image dir"},
            {"r",   "rootfs",           "kv",   nil,                                        "rootfs dir"},
        }
    }
end
task_end()

task("smart-rootfs")
do
    on_run("tasks/smart-rootfs/on_run")
    set_category("plugin")
    set_menu {
        usage = "xmake smart-rootfs [options]",
        description = "copy dependent files onto roofs",
        options = {
            {nil,   "export",           "kv",   nil,                                        "export package to build dir",
                                                                                            "    - all",
                                                                                            "    - zlib"},
            {"o",   "output",           "kv",   nil,                                        "output dir"},
            {nil,   "no-symlink",        "k",   nil,                                        "without symbolic link."},
        }
    }
end
task_end()
