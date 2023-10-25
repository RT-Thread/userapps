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
package("arm-smart-musleabi")
do
    set_kind("toolchain")
    set_homepage("https://musl.cc/")
    set_description("arm embedded compiler for rt-smart.")

    local version = os.getenv("RT_XMAKE_TOOLCHAIN_ARM_VERSION")
    local sha256 = os.getenv("RT_XMAKE_TOOLCHAIN_ARM_SHA256")

    if is_host("windows") then
        add_urls(
            "https://download-redirect.rt-thread.org/download/rt-smart/toolchains/arm-linux-musleabi_for_i686-w64-mingw32_$(version).zip")

        if (version and sha256) then
            add_versions(version, sha256)
        else
            add_versions("203958-15706d647d", "79b0e2afef8475b689ba7477d25fb67eda123d4aa135aa2d50dbac4744bc1d05")
        end
    elseif is_host("linux") then
        add_urls(
            "https://download-redirect.rt-thread.org/download/rt-smart/toolchains/arm-linux-musleabi_for_x86_64-pc-linux-gnu_$(version).tar.bz2")

        if (version and sha256) then
            add_versions(version, sha256)
        else
            add_versions("203958-15706d647d", "69d0b888297ac8236c59d90c3affcd71f831f8dc9ac058dcdfb024006f955ce3")
        end
    end

    on_install("@windows", "@linux|x86_64", function(package)
        os.vcp("*", package:installdir(), {rootdir = ".", symlink = true})
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        local gcc = "arm-linux-musleabi-gcc"
        if is_host("windows") then
            gcc = gcc .. ".exe"
        end
        local file = os.tmpfile() .. ".c"
        io.writefile(file, "int main(int argc, char** argv) {return 0;}")
        os.vrunv(gcc, {"-c", file})
    end)
end
