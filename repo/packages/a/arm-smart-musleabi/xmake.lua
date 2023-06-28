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

    if is_host("windows") then
        add_urls("http://117.143.63.254:9012/www/rt-smart/arm-linux-musleabi_for_i686-w64-mingw32_$(version).zip")

        add_versions("174629", "c059a516917a5703456c8414eecb29f1456560ff60707c8a5b352f5ef58bdb72")
    elseif is_host("linux") then
        add_urls(
            "http://117.143.63.254:9012/www/rt-smart/arm-linux-musleabi_for_x86_64-pc-linux-gnu_$(version).tar.bz2")

        add_versions("174629", "b187482fa807fbfd822eb79ee5a8c0e4e576ad3de4aa088d73b12e21c8de174a")
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
