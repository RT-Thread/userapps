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
-- 2023-05-08     xqyjlj       initial version
--
package("aarch64-smart-musleabi")
do
    set_kind("toolchain")
    set_homepage("https://musl.cc/")
    set_description("aarch64 embedded compiler for rt-smart.")

    local version = os.getenv("RT_XMAKE_TOOLCHAIN_AARCH64_VERSION")
    local sha256 = os.getenv("RT_XMAKE_TOOLCHAIN_AARCH64_SHA256")

    if is_host("windows") then
        add_urls(
            "https://download-redirect.rt-thread.org/download/rt-smart/toolchains/aarch64-linux-musleabi_for_i686-w64-mingw32_$(version).zip")

        if (version and sha256) then
            add_versions(version, sha256)
        else
            add_versions("236309-e8ed057a81", "5052119f31187202be7b5f377ef779671052e6d0f6db3009d51f46cbba1ada9a")
        end
    elseif is_host("linux") then
        add_urls(
            "https://download-redirect.rt-thread.org/download/rt-smart/toolchains/aarch64-linux-musleabi_for_x86_64-pc-linux-gnu_$(version).tar.bz2")

        if (version and sha256) then
            add_versions(version, sha256)
        else
            add_versions("236309-e8ed057a81", "3ac533662fbe412102d99546ac53776b117247cb54717c5bbdbb403b54fe1326")
        end
    end

    on_install("@windows", "@linux|x86_64", function(package)
        os.vcp("*", package:installdir(), {rootdir = ".", symlink = true})
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        local gcc = "aarch64-linux-musleabi-gcc"
        if is_host("windows") then
            gcc = gcc .. ".exe"
        end
        local file = os.tmpfile() .. ".c"
        io.writefile(file, "int main(int argc, char** argv) {return 0;}")
        os.vrunv(gcc, {"-c", file})
    end)
end
