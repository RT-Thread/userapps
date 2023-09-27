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
-- 2023-05-06     xqyjlj       initial version
-- 2023-09-17     zbtrs        update version
--
package("ffmpeg")
do
    set_homepage("https://www.ffmpeg.org")

    set_description(
        "A collection of libraries to process multimedia content such as audio, video, subtitles and related metadata.")

    add_urls("https://ffmpeg.org/releases/ffmpeg-$(version).tar.bz2")

    add_versions("5.1.3", "5d5bef6a11f0c500588f9870ec965a30acc0d54d8b1e535da6554a32902d236d")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local configs = {host = ""}
        local cc = info.cc
        local cxx = info.cxx
        local arch = info.arch
        local cpu = info.cpu
        local ldflags = {}
        local packagedeps = {}
        os.setenv("PATH", info.toolchainsdir .. ":" .. os.getenv("PATH"))

        table.insert(configs, "--cross-prefix=" .. host .. "-")
        table.insert(configs, "--enable-cross-compile")
        table.insert(configs, "--target-os=none")
        table.insert(configs, "--cc=" .. cc)
        table.insert(configs, "--cxx=" .. cxx)
        table.insert(configs, "--arch=" .. arch)
        table.insert(configs, "--cpu=" .. cpu)

        if arch == "x86_64" then
            table.insert(configs,"--disable-x86asm")
        end

        if package:config("shared") then
            table.insert(configs, "--enable-shared")
        end

        local buildenvs = import("package.tools.autoconf").buildenvs(package,
                                                                     {ldflags = ldflags, packagedeps = packagedeps})
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})

        import("package.tools.make").install(package, {}, {envs = buildenvs})

        for _, suffix in ipairs({".a", ".so"}) do
            if os.isfile(path.join(package:installdir("lib"), "libavdevice" .. suffix)) then
                package:add("links", "avdevice") -- avdevice first
            end
            if os.isfile(path.join(package:installdir("lib"), "libavfilter" .. suffix)) then
                package:add("links", "avfilter")
            end
            if os.isfile(path.join(package:installdir("lib"), "libavformat" .. suffix)) then
                package:add("links", "avformat")
            end
            if os.isfile(path.join(package:installdir("lib"), "libavcodec" .. suffix)) then
                package:add("links", "avcodec")
            end
            if os.isfile(path.join(package:installdir("lib"), "libswresample" .. suffix)) then
                package:add("links", "swresample")
            end
            if os.isfile(path.join(package:installdir("lib"), "libswscale" .. suffix)) then
                package:add("links", "swscale")
            end
            if os.isfile(path.join(package:installdir("lib"), "libavutil" .. suffix)) then
                package:add("links", "avutil")
            end
        end
    end)

    on_test(function(package)
        assert(package:has_cfuncs("avformat_open_input", {includes = "libavformat/avformat.h"}))
    end)
end
