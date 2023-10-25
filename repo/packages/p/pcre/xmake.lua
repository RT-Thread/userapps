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
-- 2023-05-05     xqyjlj       initial version
--
package("pcre")
do
    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    add_urls("https://github.com/xmake-mirror/pcre/releases/download/$(version)/pcre-$(version).tar.bz2")
    add_versions("8.45", "4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })
    add_configs("jit", {description = "Enable jit.", default = false, type = "boolean"})
    add_configs("bitwidth", {description = "Set the code unit width.", default = "8", values = {"8", "16", "32"}})

    on_install("cross@linux,windows", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local configs = {}
        local cc = info.cc
        local ldflags = {}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        table.insert(configs, "-DPCRE_BUILD_TESTS=OFF")
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DBUILD_STATIC_LIBS=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            table.insert(configs, "-DBUILD_STATIC_LIBS=ON")
        end

        if package:config("jit") then
            table.insert(configs, "-DPCRE_SUPPORT_JIT=ON")
        else
            table.insert(configs, "-DPCRE_SUPPORT_JIT=OFF")
        end

        local bitwidth = package:config("bitwidth") or "8"
        if bitwidth ~= "8" then
            table.insert(configs, "-DPCRE_BUILD_PCRE8=OFF")
            table.insert(configs, "-DPCRE_BUILD_PCRE" .. bitwidth .. "=ON")
        end

        import("package.tools.cmake").install(package, configs, {buildir = "build", ldflags = ldflags})
    end)

    on_test(function(package)
        local bitwidth = package:config("bitwidth") or "8"
        local testfunc = string.format("pcre%s_compile", bitwidth ~= "8" and bitwidth or "")
        assert(package:has_cfuncs(testfunc, {includes = "pcre.h"}))
    end)
end
