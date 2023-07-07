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
package("libpng")
do
    set_homepage("http://www.libpng.org/pub/png/libpng.html")
    set_description("The official PNG reference library")
    set_license("libpng-2.0")

    add_urls("https://github.com/glennrp/libpng/archive/$(version).zip")

    add_versions("v1.6.34", "7ffa5eb8f9f3ed23cf107042e5fec28699718916668bbce48b968600475208d3")
    add_versions("v1.6.35", "3d22d46c566b1761a0e15ea397589b3a5f36ac09b7c785382e6470156c04247f")
    add_versions("v1.6.36", "6274d3f761cc80f7f6e2cde6c07bed10c00bc4ddd24c4f86e25eb51affa1664d")
    add_versions("v1.6.37", "c2c50c13a727af73ecd3fc0167d78592cf5e0bca9611058ca414b6493339c784")
    add_versions("v1.6.38", "e1ab4aae9b88329d34bd1ca47adf3fb06c10153dbb660f4c80e2673f9fa94b24")
    add_versions("v1.6.39", "eca1ea183643d0b35a764554ede4714cf5dbc30b66845630d81b995c3b2dd571")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })

    on_load(function(package)
        package:add("deps", "zlib", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
    end)

    on_install("cross@linux", function(package)
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

        local buildenvs = import("package.tools.autoconf").buildenvs(package,
                                                                     {ldflags = ldflags, packagedeps = {"zlib"}})
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("png_create_read_struct", {includes = "png.h"}))
    end)
end
