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
-- @file        deploy.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-11     xqyjlj       initial version
--
import("rt.rt_utils")

function main(rootfs, installdir)
    for _, filepath in ipairs(os.files(path.join(installdir, "lib") .. "/lib*.so*")) do
        local filename = path.filename(filepath)
        rt_utils.cp_with_symlink(filepath, path.join(rootfs, "lib", filename))
    end
end
