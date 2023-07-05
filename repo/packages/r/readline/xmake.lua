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
-- Copyright (C) 2022-2023 RT-Thread Development Team
--
-- @author      xqyjlj
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-03-06     xqyjlj       adapt debug shared
-- 2023-03-03     xqyjlj       initial version
--
package("readline")
do
    set_homepage("https://tiswww.case.edu/php/chet/readline/rltop.html")
    set_description("Library for command-line editing")

    add_urls("https://ftp.gnu.org/gnu/readline/readline-$(version).tar.gz")
    add_urls("https://ftpmirror.gnu.org/readline/readline-$(version).tar.gz")

    add_versions("8.1", "f8ceb4ee131e3232226a17f51b164afc46cd0b9e6cef344be87c65962cb82b02")

    on_load(function(package)
        package:add("deps", "ncurses", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
    end)

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local configs = {host = host}
        local cc = info.cc
        local ldflags = {}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        if not package:config("shared") then
            table.insert(configs, "--enable-shared=no")
        else
            table.insert(configs, "--enable-shared=yes")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package)

        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("readline", {includes = {"stdio.h", "readline/readline.h"}}))
    end)
end
