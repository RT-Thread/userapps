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
-- 2023-03-06     xqyjlj       initial version
--
package("openssl")
do
    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_$(version).tar.gz", {
        version = function(version)
            return version:gsub("^(%d+)%.(%d+)%.(%d+)-?(%a*)$", "%1_%2_%3%4")
        end,
        excludes = "*/fuzz/*"
    })

    add_versions("1.1.1-i", "728d537d466a062e94705d44ee8c13c7b82d1b66f59f4e948e0cbf1cd7c461d8")

    add_patches("1.1.1-i", path.join(os.scriptdir(), "patches", "1.1.1-i", "01_crypto_mem_sec.diff"),
                "0667c3d25ace4aa416d31ad4f9e867aa7e8a1406dabe3db59da6afd228206f9c")
    add_patches("1.1.1-i", path.join(os.scriptdir(), "patches", "1.1.1-i", "02_engines_e_afalg.diff"),
                "e807384466d3f063da1b85f1ec2173d053954561a32506d58cda91fabc44bf64")
    add_patches("1.1.1-i", path.join(os.scriptdir(), "patches", "1.1.1-i", "03_include_linux_version.diff"),
                "334e52ac96629e2c0e2c35b77bfa597a22fd10c7d3b1c5ed8ac95b7275505373")

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

        if package:config("debug") then
            table.insert(configs, "--debug")
        end

        if package:config("shared") then
            table.insert(configs, "shared")
        else
            table.insert(configs, "no-shared")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package, {ldflags = ldflags})

        table.insert(configs, "linux-generic64")
        table.insert(configs, "-DOPENSSL_NO_HEARTBEATS")
        table.insert(configs, "no-threads")
        table.insert(configs, "--prefix=/")
        table.insert(configs, "--openssldir=/etc/ssl")

        os.vrunv("./Configure", configs, {envs = buildenvs})
        import("package.tools.make").build(package, {}, {envs = buildenvs})
        import("package.tools.make").make(package, {"install_sw", "DESTDIR=" .. package:installdir()},
                                          {envs = buildenvs})
        for _, suffix in ipairs({".a", ".so"}) do
            if os.isfile(path.join(package:installdir("lib"), "libssl" .. suffix)) then
                package:add("links", "ssl") -- ssl first
            end
            if os.isfile(path.join(package:installdir("lib"), "libcrypto" .. suffix)) then
                package:add("links", "crypto") -- crypto must come after ssl
            end
        end
    end)

    on_test(function(package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
end
