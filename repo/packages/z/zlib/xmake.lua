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
-- 2023-03-01     xqyjlj       add copy artifacts to "RT_XMAKE_PKG_INSTALLDIR"
-- 2023-02-28     xqyjlj       initial version
--
package("zlib")
do
    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")

    add_urls("https://github.com/madler/zlib/archive/$(version).tar.gz")

    add_versions("v1.2.8", "e380bd1bdb6447508beaa50efc653fe45f4edc1dafe11a251ae093e0ee97db9a")
    add_versions("v1.2.9", "c1e41e777e007e908ee72ee46a4be1d48b41b55af3440313f36263c08b826c4d")
    add_versions("v1.2.10", "42cd7b2bdaf1c4570e0877e61f2fdc0bce8019492431d054d3d86925e5058dc5")
    add_versions("v1.2.11", "629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff")
    add_versions("v1.2.12", "d8688496ea40fb61787500e863cc63c9afcbc524468cedeb478068924eb54932")
    add_versions("v1.2.13", "1525952a0a567581792613a9723333d7f8cc20b87a81f920fb8bc7e3f2251428")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local configs = {host = ""}
        local cc = info.cc
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        local buildenvs = import("package.tools.autoconf").buildenvs(package)

        if package:config("shared") then
            buildenvs.LDSHARED = buildenvs.CC .. " -shared -Wl,-soname,libz.so.1,--version-script,zlib.map"
        else
            table.insert(configs, "--static")
        end

        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("inflate", {includes = "zlib.h"}))
    end)
end
