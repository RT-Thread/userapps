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
-- 2023-05-04     xqyjlj       initial version
--
package("busybox")
do
    set_homepage("https://www.busybox.net/")
    set_description("BusyBox: The Swiss Army Knife of Embedded Linux.")

    add_urls("https://www.busybox.net/downloads/busybox-$(version).tar.bz2")

    add_versions("1.35.0", "faeeb244c35a348a334f4a59e44626ee870fb07b6884d68c10ae8bc19f83a694")

    add_patches("1.35.0", path.join(os.scriptdir(), "patches", "1.35.0", "01_adapt_smart.diff"),
                "a72603138d08b1280efca029b940434a4a56c5c2a8d75e1280f69c6bacf91cde")

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local version = info.version
        local host = info.host
        local cc = info.cc
        local configs = {host = ""}
        local ldflags = {}
        local cxflags = {"-O2"}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        local ldscript = rtflags.get_ldscripts(false)
        table.join2(ldflags, ldscript.ldflags)

        local sdk = rtflags.get_sdk()
        table.join2(ldflags, sdk.ldflags)
        table.join2(cxflags, sdk.cxflags)

        os.vcp(path.join(os.scriptdir(), "port", version, ".config"), ".")
        io.gsub(".config", "CONFIG_PREFIX=.-\n", 'CONFIG_PREFIX="' .. package:installdir() .. '"')

        if package:config("debug") then
            io.gsub(".config", "# CONFIG_DEBUG_PESSIMIZE is not set", 'CONFIG_DEBUG_PESSIMIZE=y')
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package, {cxflags = cxflags})
        buildenvs["CROSS_COMPILE"] = host .. "-"
        buildenvs.LDFLAGS = table.concat(ldflags, " ")
        import("package.tools.make").build(package, {}, {envs = buildenvs})
        import("package.tools.make").build(package, {"install"}, {envs = buildenvs})

        if package:config("debug") then
            os.vcp("busybox_unstripped", path.join(package:installdir("bin"), "busybox"))
        end
    end)

    on_test(function(package)
        assert(os.isfile(path.join(package:installdir("bin"), "busybox")))
    end)
end
