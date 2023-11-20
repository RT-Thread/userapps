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
-- 2023-03-07     xqyjlj         initial version
--
package("lua")
do
    set_homepage("http://lua.org")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    add_urls("https://www.lua.org/ftp/lua-$(version).tar.gz")

    add_versions("5.1.4", "b038e225eaf2a5b57c9bcc35cd13aa8c6c8288ef493d52970c9545074098af3a")

    add_patches("5.1.4", path.join(os.scriptdir(), "patches", "5.1.4", "01_makefile.diff"),
                "ce22ca035ebc054876005aa252c2284266c1f34706b12f7219165dbcd5797e4b")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })

    on_load(function(package)
        package:add("deps", "readline", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
        package:add("deps", "ncurses", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
    end)

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local configs = {host = host}
        local cc = info.cc
        local ldflags = {}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        local buildenvs = import("package.tools.autoconf").buildenvs(package, {
            ldflags = ldflags,
            packagedeps = {"readline", "ncurses"}
        })

        buildenvs.LDFLAGS = string.gsub(buildenvs.LDFLAGS, " %-lncurses%+%+_g", "")
        buildenvs.LDFLAGS = string.gsub(buildenvs.LDFLAGS, " %-lncurses%+%+", "")

        table.insert(configs, "generic")
        configs.INSTALL_TOP = package:installdir()

        import("package.tools.make").build(package, configs, {
            envs = {CROSS_COMPILE = host .. "-", MYCFLAGS = buildenvs.CFLAGS, MYLDFLAGS = buildenvs.LDFLAGS}
        })
        table.insert(configs, "install")
        import("package.tools.make").build(package, configs, {
            envs = {CROSS_COMPILE = host .. "-", MYCFLAGS = buildenvs.CFLAGS, MYLDFLAGS = buildenvs.LDFLAGS}
        })
    end)

    on_test(function(package)
        assert(package:has_cfuncs("lua_getinfo", {includes = "lua.h"}))
    end)
end
