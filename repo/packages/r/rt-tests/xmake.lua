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
-- 2023-04-17     xqyjlj       initial version
--
package("rt-tests")
do
    set_homepage("https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests")
    set_description("suite of real-time tests")

    add_urls("https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git/snapshot/rt-tests-$(version).tar.gz")

    add_versions("1.0", "c543672cdeeb9033284b55ea64a7c7c7c385949646332dfbdd295cbedbf610b8")

    add_patches("1.0", path.join(os.scriptdir(), "patches", "1.0", "01_stable_v1.0.diff"),
                "45068026d52fb21a3ed205255f3da563e64a4ebacca8cb692612b3769bfafc0c")
    add_patches("1.0", path.join(os.scriptdir(), "patches", "1.0", "02_cyclictest_c.diff"),
                "5bac2ea74f34bd986ab69a1ef8c4a0f3df99c166369bcb919e98b8a830742b59")
    add_patches("1.0", path.join(os.scriptdir(), "patches", "1.0", "03_Makefile.diff"),
                "1ecdb0083170492118da7d98fb2cbebde80d3e1f9f92f0fcb5e577cdf1f03c47")
    add_patches("1.0", path.join(os.scriptdir(), "patches", "1.0", "04_cyclictest_signed.diff"),
                "70c5730323fe17219b5953e0c7fb6ed6de0c306fd4e1efabc39ca3dd6ed01780")
    add_patches("1.0", path.join(os.scriptdir(), "patches", "1.0", "05_fix_high_resolution_timers_check.diff"),
                "deae130cd138ce85f3554821754c36bc624105224045e6c85231cde92163a026")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })
    add_configs("cyclictest", {description = "high resolution test program", default = true, type = "boolean"})

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local cc = info.cc
        local ldflags = {}
        local configs = {}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        if info.arch == "x86_64" then
            table.insert(configs, "NUMA=0")
        end
        local buildenvs = import("package.tools.autoconf").buildenvs(package, {ldflags = ldflags})
        buildenvs["prefix"] = package:installdir()
        if package:config("cyclictest") then
            table.insert(configs, "cyclictest")
        end
        if package:config("debug") then
            table.insert(configs, "DEBUG=1")
        end

        import("package.tools.make").build(package, configs, {envs = buildenvs})

        if package:config("cyclictest") then
            os.vcp("cyclictest", package:installdir("bin"))
            os.vcp("src/cyclictest/cyclictest.8", package:installdir("share/man"))
        end
    end)

    on_test(function(package)
        if package:config("cyclictest") then
            assert(os.isfile(path.join(package:installdir("bin"), "cyclictest")))
        end
    end)
end
