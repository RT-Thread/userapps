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
-- 2023-09-01     zbtrs        initial version
--
package("dropbear")
do
    set_homepage("https://matt.ucc.asn.au/dropbear/dropbear.html")
    set_description("Dropbear is a relatively small SSH server and client. It runs on a variety of unix platforms. Dropbear is open source software, distributed under a MIT-style license. Dropbear is particularly useful for embedded-type Linux (or other Unix) systems, such as wireless routers.")
    
    add_urls("https://matt.ucc.asn.au/dropbear/releases/dropbear-$(version).tar.bz2")
    
    add_versions("2022.83","bc5a121ffbc94b5171ad5ebe01be42746d50aa797c9549a4639894a16749443b")

    add_patches("2022.83",path.join(os.scriptdir(), "patches", "2022.83", "01_adapt_smart.diff"),
                "b15127fcee613fe7771d8f8dcc93b0ea3739ac6b3a2b06c99d51456fa8f81606")
    add_patches("2022.83",path.join(os.scriptdir(), "patches", "2022.83", "03_fix_memory.diff"),
                "a12b7ee10502d47994c089e39b5b30640516971323eed9af93cdf96bcdc7815d")
                
    on_load(function(package)
        package:add("deps", "zlib", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
    end)


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
            ldflags = ldflags,
            packagedeps = {"zlib"}
        })

        buildenvs["CROSS_COMPILE"] = host .. "-"
        buildenvs.LDFLAGS = table.concat(ldflags, " ")        
        local zlib_path = buildenvs["PKG_CONFIG_PATH"] .. "/.." .. "/.."
        table.insert(configs,"--with-zlib=" .. zlib_path)

        import("package.tools.autoconf").configure(package,configs,{envs = buildenvs})
        import("package.tools.make").build(package, {PROGRAMS = "dropbear dbclient dropbearkey dropbearconvert scp"}, {envs = buildenvs})
        import("package.tools.make").build(package, {PROGRAMS = "dropbear dbclient dropbearkey dropbearconvert scp","install"}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(os.isfile(path.join(package:installdir("bin"), "dropbearkey")))
    end)

end