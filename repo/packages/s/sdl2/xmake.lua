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
-- 2023-05-22     xqyjlj       initial version
--
package("sdl2")
do
    set_homepage("https://libsdl.org/")
    set_description("Simple DirectMedia Layer.")

    add_urls("https://github.com/libsdl-org/SDL/archive/refs/tags/release-$(version).tar.gz")

    add_versions("2.0.14", "f85233bc8d4f30a7caa5aea7de0f95b8f4b1f7272473aea4b3ec4ede0a27357f")

    add_patches("2.0.14", path.join(os.scriptdir(), "patches", "2.0.14", "01_adapt_smart.diff"),
                "b23de0d3b13dd7d3a12a07a94ec84d51c78c9960058730d920e321871418e12b")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    add_includedirs("include", "include/SDL2")

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

        table.insert(configs, "--build=i686-pc-linux-gnu")
        table.insert(configs, "--enable-joystick-virtual=no")
        table.insert(configs, "--enable-render-d3d=no")
        table.insert(configs, "--enable-sdl-dlopen=no")
        table.insert(configs, "--enable-joystick=no")
        table.insert(configs, "--enable-joystick-mfi=no")
        table.insert(configs, "--enable-hidapi=no")
        table.insert(configs, "--enable-hidapi-libusb=no")
        table.insert(configs, "--enable-threads=no")
        table.insert(configs, "--enable-3dnow=no")
        table.insert(configs, "--enable-jack-shared=no")
        table.insert(configs, "--enable-pulseaudio-shared=no")
        table.insert(configs, "--enable-pulseaudio=no")
        table.insert(configs, "--enable-cpuinfo=no")
        table.insert(configs, "--enable-video-directfb")
        table.insert(configs, "--enable-directfb-shared=no")
        table.insert(configs, "--enable-video-rtt-virtio-gpu=no")
        table.insert(configs, "--enable-video-rtt-touch=no")
        table.insert(configs, "--enable-video-rtt-fbdev=yes")

        local buildenvs = import("package.tools.autoconf").buildenvs(package, {ldflags = ldflags})
        os.vrun("./autogen.sh", {envs = buildenvs})
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("SDL_Init", {includes = {"SDL.h"}}))
    end)
end
