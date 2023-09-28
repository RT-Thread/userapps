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
-- @author      zbtrs
-- @file        xmake.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-09-08     zbtrs        initial version
--
package("sftp_server")
do
    set_homepage("https://github.com/zbtrs/sftpserver")
    set_description("This is an SFTP server supporting up to protocol version 6. It is possible to use it as a drop-in replacement for the OpenSSH server.")
    
    add_urls("https://github.com/zbtrs/sftpserver/archive/refs/tags/V$(version).tar.gz")
    
    add_versions("1.0","2ee448f196ed1132ca60fc6bb7d49285419058433f892380d8aee75059be4c87")

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local version = info.version
        local host = info.host
        local cc = info.cc
        local configs = {host = host}
        local ldflags = {}
        local cxflags = {}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))
        print(path.directory(cc))

        local ldscript = rtflags.get_ldscripts(false)
        table.join2(ldflags, ldscript.ldflags)

        local sdk = rtflags.get_sdk()
        table.join2(ldflags, sdk.ldflags)
        table.join2(cxflags, sdk.cxflags)

        local buildenvs = import("package.tools.autoconf").buildenvs(package, {
            cxflags = cxflags,
            ldflags = ldflags
        })

        buildenvs["CROSS_COMPILE"] = host .. "-"
        buildenvs.LDFLAGS = table.concat(ldflags, " ")        
        table.insert(configs,"--disable-largefile")
        table.insert(configs,"--with-threads=1")
        os.vrun("./autogen.sh", {envs = buildenvs})
        import("package.tools.autoconf").configure(package,configs,{envs = buildenvs})
        import("package.tools.make").build(package, {}, {envs = buildenvs})
        import("package.tools.make").build(package, {"install"}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(os.isfile(path.join(package:installdir("libexec"), "gesftpserver")))
    end)

end