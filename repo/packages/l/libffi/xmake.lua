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
package("libffi")
do
    set_homepage("https://sourceware.org/libffi/")
    set_description("Portable Foreign Function Interface library.")

    add_urls("https://github.com/libffi/libffi/releases/download/v$(version)/libffi-$(version).tar.gz")

    add_versions("3.4.4", "d66c56ad259a82cf2a9dfc408b32bf5da52371500b84745f7fb8b645712df676")

    add_patches("3.4.4", path.join(os.scriptdir(), "patches", "3.4.4", "01_src_tramp.diff"),
                "6a16954ca8c1b1549b2f0eae369b1abe11cdbb70e7d1e94c32f94defbae4bc60")

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
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        if package:config("debug") then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end

        table.insert(configs, "--enable-static=yes")
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package)

        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
        local lib64 = path.join(package:installdir(), "lib64")
        if os.isdir(lib64) then
            package:add("links", "ffi")
            package:add("linkdirs", "lib64")
        end
    end)

    on_test(function(package)
        assert(package:has_cfuncs("ffi_closure_alloc", {includes = "ffi.h"}))
    end)
end
