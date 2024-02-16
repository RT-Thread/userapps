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
-- 2023-05-06     xqyjlj       initial version
--
package("sdl2_image")
do
    set_homepage("https://libsdl.org/")
    set_description("Simple DirectMedia Layer.")

    add_urls("https://github.com/libsdl-org/SDL_image/archive/refs/tags/release-$(version).tar.gz")

    add_versions("2.0.5", "76b7f67f4c1a5f8368658f0e1e59bdaa4555d1cc7f3a4413178cd735019983ff")

    add_configs("shared", {
        description = "Build shared library.",
        default = os.getenv("RT_XMAKE_LINK_TYPE") ~= "static",
        type = "boolean"
    })

    local features = {
        bmp = {boolean = true, package = nil},
        gif = {boolean = false, package = "unsupport!!!"},
        jpg = {boolean = true, package = "libjpeg"},
        lbm = {boolean = false, package = "unsupport!!!"},
        pcx = {boolean = false, package = "unsupport!!!"},
        png = {boolean = true, package = "libpng"},
        pnm = {boolean = false, package = "unsupport!!!"},
        svg = {boolean = false, package = "unsupport!!!"},
        tga = {boolean = false, package = "unsupport!!!"},
        tif = {boolean = false, package = "unsupport!!!"},
        xcf = {boolean = false, package = "unsupport!!!"},
        xpm = {boolean = false, package = "unsupport!!!"},
        xv = {boolean = false, package = "unsupport!!!"},
        webp = {boolean = false, package = "unsupport!!!"}
    }

    for feature, cfg in pairs(features) do
        add_configs(feature,
                    {description = "enable " .. feature .. " support.", default = cfg.boolean, type = "boolean"})
    end

    on_load(function(package)
        package:add("deps", "zlib", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
        package:add("deps", "sdl2", {debug = package:config("debug"), configs = {shared = package:config("shared")}})
        for feature, cfg in pairs(features) do
            if package:config(feature) and cfg.package then
                package:add("deps", cfg.package,
                            {debug = package:config("debug"), configs = {shared = package:config("shared")}})
            end
        end

    end)

    on_install("cross@linux", function(package)
        import("rt.private.build.rtflags")
        local info = rtflags.get_package_info(package)
        local host = info.host
        local configs = {host = host}
        local cc = info.cc
        local ldflags = {}
        os.setenv("PATH", path.directory(cc) .. ":" .. os.getenv("PATH"))
        local sdl2 = package:dep("sdl2")
        local packagedeps = {"sdl2", "zlib"}

        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-shared=no")
            table.insert(configs, "--enable-static=yes")
        end

        table.insert(configs, "--enable-jpg-shared=no")
        table.insert(configs, "--enable-png-shared=no")
        table.insert(configs, "--enable-tif-shared=no")
        table.insert(configs, "--enable-webp-shared=no")

        for feature, cfg in pairs(features) do
            if package:config(feature) and cfg.package then
                table.insert(packagedeps, cfg.package)
            end
            table.insert(configs, string.format("--enable-%s=%s", feature, package:config(feature) and "yes" or "no"))
        end

        table.insert(configs, "--build=i686-pc-linux-gnu")
        table.insert(configs, "--with-sdl-prefix=" .. sdl2:installdir())

        local buildenvs = import("package.tools.autoconf").buildenvs(package,
                                                                     {ldflags = ldflags, packagedeps = packagedeps})
        -- os.vrun("autoreconf -fiv || true", {envs = buildenvs})
        import("package.tools.autoconf").configure(package, configs, {envs = buildenvs})
        import("package.tools.make").install(package, {}, {envs = buildenvs})
    end)

    on_test(function(package)
        assert(package:has_cfuncs("IMG_Init", {includes = "SDL2/SDL_image.h", configs = {defines = "SDL_MAIN_HANDLED"}}))
    end)
end
