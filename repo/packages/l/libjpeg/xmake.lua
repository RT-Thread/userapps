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
-- 2023-02-28     xqyjlj       initial version
--
package("libjpeg")
do
    set_homepage("http://ijg.org/")
    set_description("A widely used C library for reading and writing JPEG image files.")

    add_urls("https://www.ijg.org/files/jpegsrc.$(version).tar.gz")

    add_versions("v9b", "566241ad815df935390b341a5d3d15a73a4000e5aab40c58505324c2855cbbb8")
    add_versions("v9c", "682aee469c3ca857c4c38c37a6edadbfca4b04d42e56613b11590ec6aa4a278d")
    add_versions("v9d", "2303a6acfb6cc533e0e86e8a9d29f7e6079e118b9de3f96e07a71a11c082fa6a")
    add_versions("v9e", "4077d6a6a75aeb01884f708919d25934c93305e49f7e3f36db9129320e6f4f3d")

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

        table.insert(configs, "--enable-static=yes")
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package, {ldflags = ldflags})
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("jpeg_create_compress(0)", {includes = {"stdio.h", "jpeglib.h"}}))
    end)
end
