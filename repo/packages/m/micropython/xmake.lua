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
-- 2023-06-25     xqyjlj       initial version
--
package("micropython")
do
    set_homepage("https://micropython.org/")
    set_description("MicroPython is a lean and efficient implementation of the Python 3 programming language.")

    add_urls("https://github.com/micropython/micropython/releases/download/v$(version)/micropython-$(version).tar.xz")

    add_versions("1.20.0", "098ef8e40abdc62551b5460d0ffe9489074240c0cb5589ca3c3a425551beb9bf")

    add_patches("1.20.0", path.join(os.scriptdir(), "patches", "1.20.0", "01_adapt_smart.diff"),
                "d0eb05d02339977f9c5771dcc81d2a616962ec57cb4d272fe8da3b8b22cc830c")

    add_patches("1.20.0", path.join(os.scriptdir(), "patches", "1.20.0", "02_fix_gcc13.diff"),
                "3b9ac8febc3582c8c914c9c8f53340a78b417c7d707aafd8c63585b34fa55454")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })
    add_configs("with_ffi", {description = "use libffi library.", default = false, type = "boolean"})

    on_load(function(package)
        if package:config("with_ffi") then
            package:add("deps", "libffi",
                        {debug = package:config("debug"), configs = {shared = package:config("shared")}})
        end
    end)

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local version = info.version
        local host = info.host
        local cc = info.cc
        local configs = {host = ""}
        local cxflags = {}
        local packagedeps = {}

        if package:config("with_ffi") then
            table.insert(cxflags, "-DMICROPY_FORCE_PLAT_ALLOC_EXEC=0")
            table.insert(packagedeps, "libffi")
        else
            io.gsub("ports/unix/mpconfigport.mk", "MICROPY_PY_FFI =.-\n", 'MICROPY_PY_FFI = 0')
        end

        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        local buildenvs = import("package.tools.autoconf").buildenvs(package,
                                                                     {cxflags = cxflags, packagedeps = packagedeps})

        import("package.tools.make").build(package, {"-C", "mpy-cross"}, {envs = {}})
        import("package.tools.make").build(package, {"-C", "ports/unix", "VARIANT=standard"}, {
            envs = {CROSS_COMPILE = host .. "-", LDFLAGS = buildenvs.LDFLAGS, CFLAGS_EXTRA = buildenvs.CFLAGS}
        })
        os.vcp("ports/unix/build-standard/micropython", package:installdir("bin"))
    end)

    on_test(function(package)
        assert(os.isfile(path.join(package:installdir("bin"), "micropython")))
    end)
end
