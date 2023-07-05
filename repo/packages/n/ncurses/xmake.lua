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
-- 2023-03-02     xqyjlj       initial version
--
package("ncurses")
do
    set_homepage("https://www.gnu.org/software/ncurses/")
    set_description("A free software emulation of curses.")

    add_urls("https://ftpmirror.gnu.org/ncurses/ncurses-$(version).tar.gz")
    add_urls("https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(version).tar.gz")
    add_urls("https://invisible-mirror.net/archives/ncurses/ncurses-$(version).tar.gz")

    add_versions("6.4", "6931283d9ac87c5073f30b6290c4c75f21632bb4fc3603ac8100812bed248159")

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

        table.insert(configs, "--disable-stripping")
        table.insert(configs, "--with-terminfo-dirs=/etc/terminfo:/lib/terminfo:/usr/share/terminfo")
        if package:config("debug") then
            table.insert(configs, "--with-debug")
            table.insert(configs, "--with-trace")

        else
            table.insert(configs, "--without-debug")
            table.insert(configs, "--without-trace")
        end

        table.insert(ldflags, "-lstdc++")
        if package:config("shared") then
            table.insert(configs, "--with-shared")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package, {ldflags = ldflags})
        buildenvs.ARFLAGS = ""
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("initscr", {includes = "ncurses/ncurses.h"}))
    end)
end
