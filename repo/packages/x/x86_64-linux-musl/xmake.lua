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
-- 2023-05-18     xqyjlj       initial version
--
package("x86_64-linux-musl")
do
    set_kind("toolchain")
    set_homepage("https://musl.cc/")
    set_description("x86_64 cross compiler for linux.")

    if is_host("windows") then
        add_urls(
            "https://download-redirect.rt-thread.org/download/rt-smart/native/toolchains/x86_64-linux-musl-cross-$(version).win.zip")
        add_versions("20210202", "3a13f8bb3694b26ffbe3fe97d45db6cabadb662161cd5fc9cc80fc0adfb02091")
    elseif is_host("linux") then
        add_urls(
            "https://download-redirect.rt-thread.org/download/rt-smart/native/toolchains/x86_64-linux-musl-cross-$(version).linux.tgz")
        add_versions("20210202", "37ef7b69d4c4a20bb2c5e7e01ec7c60c1ac7de2c33b029eaa6c0d8b9e1869c6b")
    end

    on_install("@windows", "@linux|x86_64", function(package)
        os.vcp("*", package:installdir(), {rootdir = ".", symlink = true})
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        local gcc = "x86_64-linux-musl-gcc"
        if is_host("windows") then
            gcc = gcc .. ".exe"
        end
        local file = os.tmpfile() .. ".c"
        io.writefile(file, "int main(int argc, char** argv) {return 0;}")
        os.vrunv(gcc, {"-c", file})
    end)
end
