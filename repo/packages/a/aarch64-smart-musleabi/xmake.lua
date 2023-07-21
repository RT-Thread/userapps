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

    if is_host("windows") then
        add_urls("http://117.143.63.254:9012/www/rt-smart/aarch64-linux-musleabi_for_i686-w64-mingw32_$(version).zip")

        add_versions("184869", "9dd15ff69ce44270aaccd05ccd038bad15baf60f2e4f0dafadc570a51b2eabde")
    elseif is_host("linux") then
        add_urls(
            "http://117.143.63.254:9012/www/rt-smart/aarch64-linux-musleabi_for_x86_64-pc-linux-gnu_$(version).tar.bz2")

        add_versions("184869", "81c62acbdec8076bbbde564891798c84eeec3db1af40383600aec4fdc3a59fca")
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
