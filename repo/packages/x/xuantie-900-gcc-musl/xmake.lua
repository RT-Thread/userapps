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
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-12     xqyjlj       initial version
--
package("xuantie-900-gcc-musl")
do
    set_kind("toolchain")
    set_homepage("https://www.xrvm.cn/")
    set_description("riscv64 xuantie embedded compiler for rt-smart.")

    local version = os.getenv("RT_XMAKE_TOOLCHAIN_XUANTIE_VERSION")
    local sha256 = os.getenv("RT_XMAKE_TOOLCHAIN_XUANTIE_SHA256")
        
    if is_host("linux") then
        add_urls(
            "https://github.com/RT-Thread/toolchains-ci/releases/download/v1.9/Xuantie-900-gcc-linux-6.6.0-musl64-x86_64-V$(version).tar.gz")

        if (version and sha256) then
            add_versions(version, sha256)
        else
            add_versions("3.0.2", "26b338747a10cc32c8b83f340ce1980b786e7a0445380a70544867b6ed10199b")
        end
    end

    on_install("@windows", "@linux|x86_64", function(package)
        os.vcp("*", package:installdir(), {rootdir = ".", symlink = true})
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        local gcc = "riscv64-unknown-linux-musl-gcc"
        if is_host("windows") then
            gcc = gcc .. ".exe"
        end
        local file = os.tmpfile() .. ".c"
        io.writefile(file, "int main(int argc, char** argv) {return 0;}")
        os.vrunv(gcc, {"-c", file})
    end)
end
