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
-- @author      zbtrs
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-08-13     zbtrs        initial version
--
package("wolfssl")
do
    set_homepage("https://www.wolfssl.com/")
    set_description("Providing secure communication for IoT, smart grid, connected home, automobiles, routers, applications, games, IP, mobile phones, the cloud, and more.")

    add_urls("https://github.com/wolfSSL/wolfssl/archive/refs/tags/$(version)-stable.tar.gz")
    add_versions("v5.6.3","2e74a397fa797c2902d7467d500de904907666afb4ff80f6464f6efd5afb114a")

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
        table.insert(configs,"--enable-sslv3=yes")
        table.insert(configs,"--enable-ecc=yes")
        table.insert(configs,"--enable-tlsx=yes")
        table.insert(configs,"--enable-stunnel=yes")
        table.insert(configs,"--enable-opensslextra=yes")
        table.insert(configs,"--enable-openssh=yes")
        table.insert(configs,"--enable-tlsv10=yes")
        
        local buildenvs = import("package.tools.autoconf").buildenvs(package, {ldflags = ldflags})
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)


end