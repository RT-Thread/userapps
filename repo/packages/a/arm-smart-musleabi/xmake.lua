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
package("arm-smart-musleabi")
do
    set_kind("toolchain")
    set_homepage("https://musl.cc/")
    set_description("arm embedded compiler for rt-smart.")

    if is_host("windows") then
        add_urls("http://117.143.63.254:9012/www/rt-smart/arm-linux-musleabi_for_i686-w64-mingw32_$(version).zip")

        add_versions("179876", "d663918ed890143f875368e7eb02472f2c36df1233a8d02e872df9a83274759f")
    elseif is_host("linux") then
        add_urls(
            "http://117.143.63.254:9012/www/rt-smart/arm-linux-musleabi_for_x86_64-pc-linux-gnu_$(version).tar.bz2")

        add_versions("179876", "a8962d2c8b56b54148f3848803b28bc727282b774548763db34eb61a58647cee")
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
