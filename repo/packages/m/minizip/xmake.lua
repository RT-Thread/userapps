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
-- @author      wcx1024979076
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author         Notes
-- ------------   ----------     -----------------------------------------------
-- 2023-07-26     wcx1024979076  initial version
--

package("minizip")
    set_homepage("https://www.zlib.net/")
    set_description("Mini zip and unzip based on zlib")
    set_license("zlib")

    add_urls("https://github.com/madler/zlib/archive/$(version).tar.gz",
             "https://github.com/madler/zlib.git")
    add_versions("v1.2.10", "42cd7b2bdaf1c4570e0877e61f2fdc0bce8019492431d054d3d86925e5058dc5")
    add_versions("v1.2.11", "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff")
    add_versions("v1.2.12", "d8688496ea40fb61787500e863cc63c9afcbc524468cedeb478068924eb54932")
    add_versions("v1.2.13", "1525952a0a567581792613a9723333d7f8cc20b87a81f920fb8bc7e3f2251428")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })

    on_load(function(package)
        package:add("deps", "zlib", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
    end)

    on_install(function (package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local configs = {host = host}
        local cc = info.cc
        local ldflags = {}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        table.insert(configs, "--enable-static=yes")
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end

        os.cd(path.join("contrib", "minizip"))

        local buildenvs = import("package.tools.autoconf").buildenvs(package,
                                                                     {ldflags = ldflags, packagedeps = {"zlib"}})
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "minizip/zip.h"}))
    end)
