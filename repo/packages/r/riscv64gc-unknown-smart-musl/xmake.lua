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
-- @author      zhouquan
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-12     zhouquan     initial version
--
package("riscv64gc-unknown-smart-musl")
do
    set_kind("toolchain")
    set_homepage("https://musl.cc/")
    set_description("riscv64 embedded compiler for rt-smart.")

    if is_host("windows") then
        add_urls(
            "https://download.rt-thread.org/rt-smart/riscv64/riscv64-linux-musleabi_for_i686-w64-mingw32_$(version).zip")

        add_versions("180881", "7b385fe663559985d70936832dc0f6c017ce3bddbdbfaff673996cc3a20faf6c")
    elseif is_host("linux") then
        add_urls(
            "https://download.rt-thread.org/rt-smart/riscv64/riscv64-linux-musleabi_for_x86_64-pc-linux-gnu_$(version).tar.bz2")

        add_versions("180881", "21ad2cbd9b4e73e61efd8211b88c3989acaa033a374ac2f26b4e15a7ec7370b6")
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
