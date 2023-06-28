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
-- 2023-05-27     xqyjlj       initial version
--
task("smart-create")
do
    -- set category
    set_category("plugin")

    -- on run
    on_run("main")

    -- set menu
    set_menu {
        -- usage
        usage = "xmake smart-create [options] [target]",
        description = "Create a new project for rt-thread smart.",
        options = {
            {'f',   "force",    "k",    nil,                        "Force to create project in a non-empty directory."},
            {'t',   "template", "kv",   "helloworld",               "Select the project template id or name of the given language.",
                                                                    '    - helloworld: Create "hello world" project',
                                                                    '    - lib: Create a lib project based on "<package>"',
                                                                    '    - app: Create a app project based on "busybox"'},
            {'p',   "package",  "kv",   "zlib",                     "Force to create project in a non-empty directory."},
            {},
            {nil,   "target",   "v",    nil,                        "Create the given target.",
                                                                    "Uses the project name as target if not exists."}
        }
    }
end
