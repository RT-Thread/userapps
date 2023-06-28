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
-- 2023-03-07     xqyjlj         initial version
--
package("uhttpd")
do
    set_homepage("https://openwrt.org/docs/guide-user/services/webserver/http.uhttpd")
    set_description("a web server written to be an efficient and stable server.")

    add_urls("https://github.com/xqyjlj/uhttpd/archive/refs/tags/$(version).tar.gz")

    add_versions("v21", "171ee5a9188480ea6c70d52d7226e33c9c1fa942e9d1d8a31a75b86a0262e096")

    add_patches("v21", path.join(os.scriptdir(), "patches", "v21", "01_makefile.diff"),
                "4033da4550957f37122b650cb7195e13282b3e5cd1f9eedb6e15ec2440cb27da")
    add_patches("v21", path.join(os.scriptdir(), "patches", "v21", "02_uhttpd.diff"),
                "3723479bd6141d1d0d706962806fb10c91a949435d481b1193dc1e0c9c7ac3b1")

    add_deps("lua", {configs = {shared = false}})
    add_deps("openssl", {configs = {shared = false}})

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local cc = info.cc
        local configs = {host = host}
        local ldflags = {"-L."}
        local cxflags = {"-O2"}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))

        table.insert(ldflags, "--static")
        local ldscript = rtflags.get_ldscripts(false)
        table.join2(ldflags, ldscript.ldflags)

        local sdk = rtflags.get_sdk()
        table.join2(ldflags, sdk.ldflags)
        table.join2(cxflags, sdk.cxflags)

        local lua = package:dep("lua"):fetch()
        local openssl = package:dep("openssl"):fetch()
        table.insert(ldflags, "-L" .. lua.linkdirs[1])
        table.insert(ldflags, "-llua")
        table.insert(ldflags, "-L" .. openssl.linkdirs[1])
        table.insert(ldflags, "-lssl")
        table.insert(ldflags, "-lcrypto")
        local buildenvs = import("package.tools.autoconf").buildenvs(package, {
            cxflags = cxflags,
            ldflags = ldflags,
            packagedeps = {"lua", "openssl"}
        })
        buildenvs.LDFLAGS = table.concat(ldflags, " ")
        import("package.tools.make").build(package, {}, {envs = buildenvs})
        os.vcp("uhttpd", package:installdir("bin"))
    end)

    on_test(function(package)
        assert(os.isfile(path.join(package:installdir("bin"), "uhttpd")))
    end)
end
