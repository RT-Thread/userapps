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
-- @author      zhouquan
-- @file        on_run.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-09     zhouquan     initial version
--
import("core.project.config")
import("core.project.project")
import("core.package.package")
import("core.base.option")
import("rt.rt_utils")

function create_dir(dir)
    if not os.exists(dir) then
        os.mkdir(dir)
    end
end

function create_rootfs(rootfs)
    create_dir(path.join(rootfs, "bin"))
    create_dir(path.join(rootfs, "dev"))
    create_dir(path.join(rootfs, "etc"))
    create_dir(path.join(rootfs, "kernel"))
    create_dir(path.join(rootfs, "lib"))
    create_dir(path.join(rootfs, "proc"))
    create_dir(path.join(rootfs, "mnt"))
    create_dir(path.join(rootfs, "services"))
    create_dir(path.join(rootfs, "tmp"))
    create_dir(path.join(rootfs, "usr"))
    create_dir(path.join(rootfs, "var", "persistence"))
    create_dir(path.join(rootfs, "var", "run"))
end

function deploy_package(rootfs)
    local rootdir = path.absolute("../../../../repo", os.scriptdir())
    for pkgname, pkg in pairs(project:required_packages()) do
        local packagename = string.match(pkgname, "[^@~]+")
        local deploy_script =
            path.join(rootdir, "packages", packagename:sub(1, 1), packagename, "scripts", "deploy.lua")
        if os.isfile(deploy_script) then
            vprint("run script => '%s'", deploy_script)
            import("deploy", {rootdir = path.directory(deploy_script)}).main(rootfs, pkg:installdir())
        end
        local package_rootfs = path.join(rootdir, "packages", packagename:sub(1, 1), packagename, "rootfs")
        if os.isdir(package_rootfs) then
            for _, filedir in ipairs(os.filedirs(package_rootfs .. "/*")) do
                os.vrunv("cp", {"-rfv", filedir, rootfs})
            end
        end
    end
end

function export_package_to_sdkdir(sdkdir)
    local rootdir = path.absolute("../../../../repo", os.scriptdir())
    for pkgname, pkg in pairs(project:required_packages()) do
        local packagename = string.match(pkgname, "[^@~]+")
        local export_script =
            path.join(rootdir, "packages", packagename:sub(1, 1), packagename, "scripts", "export.lua")
        if os.isfile(export_script) then
            vprint("run script => '%s'", export_script)
            import("export", {rootdir = path.directory(export_script)}).main(sdkdir, pkg:installdir())
        end
    end
end

function deploy_target(rootfs)
    for targetname, target in pairs(project.targets()) do
        local targetfile = target:targetfile()
        if targetfile then
            local srcpath = target:targetfile()
            local artifact_dir = path.join(config.buildir(), config.plat(), config.arch(), config.mode())
            targetfile = path.relative(targetfile, artifact_dir)
            local dstpath = path.join(rootfs, "bin", targetfile)
            cprint("${dim}> copy %s to %s", srcpath, dstpath)
            os.cp(srcpath, dstpath)
        end
    end
end

function deploy_syslib(toolchains, rootfs)
    local sdkdir = rt_utils.sdk_dir()
    local arch = config.arch()
    local pkg = project:required_packages()[toolchains]

    if string.startswith(toolchains, "riscv64") then
        toolchains = "riscv64-unknown-smart-musl"
    end

    toolchains = string.gsub(toolchains, "smart", "linux") -- TODO: should replace, when toolchains renamed

    if arch == "arm64" then
        arch = "aarch64"
    end

    if arch == "arm" then
        arch = "arm/cortex-a"
    elseif arch == "aarch64" then
        arch = "aarch64/cortex-a"
    end

    local rtlibdir = path.join(sdkdir, "rt-thread", "lib", arch)
    local libdir = path.join(sdkdir, "lib", arch)
    for _, filepath in ipairs(os.files(rtlibdir .. "/*.so*")) do
        local filename = path.filename(filepath)
        rt_utils.cp_with_symlink(filepath, path.join(rootfs, "lib", filename))
    end
    for _, filepath in ipairs(os.files(libdir .. "/*.so*")) do
        local filename = path.filename(filepath)
        rt_utils.cp_with_symlink(filepath, path.join(rootfs, "lib", filename))
    end

    for _, filepath in ipairs(os.files(path.join(pkg:installdir(), toolchains) .. "/*/lib*.so*")) do
        if path.extension(filepath) ~= ".py" then
            local filename = path.filename(filepath)
            rt_utils.cp_with_symlink(filepath, path.join(rootfs, "lib", filename))
        end
    end
end

function copy_packages()
    local name = option.get("export")
    if name == "all" then
        os.exec("xmake require --export")
    else
        os.exec("xmake require --export " .. name)
    end

    local packagedir = path.join(project.directory(), "packages")
    local build = path.join(project.directory(), config.buildir(), "packages")
    if os.isdir(packagedir) then
        if os.isdir(build) then
            os.rm(build)
        end
        os.mv(packagedir, path.join(project.directory(), config.buildir(), "packages"))
    end
end

function main()
    config.load()
    -- project.load_targets()

    if option.get("export") then
        local sdkdir = ""
        local userapps_dir = os.getenv("RT_XMAKE_USERAPPS_DIR")

        if userapps_dir then
            sdkdir = path.join(userapps_dir, "sdk")
        else
            sdkdir = path.join(project.directory(), config.buildir(), "sdk")
        end
        copy_packages()
        export_package_to_sdkdir(sdkdir)
    else
        local targetname = table.orderkeys(project.targets())[1]
        local target = project.targets()[targetname]
        local toolchains = string.gsub(target:get("toolchains"), "@", "")
        local rootfs = option.get("output") or rt_utils.rootfs_dir()

        if (option.get("no-symlink")) then
            os.setenv("--rt-xmake-no-symlink", "true")
        end

        create_rootfs(rootfs)
        deploy_package(rootfs)
        deploy_target(rootfs)
        deploy_syslib(toolchains, rootfs)

        local size = rt_utils.dirsize(rootfs)
        cprint("${green}> rootfs: %s", rootfs)
        cprint("${green}> done, rootfs size: %s", size)
    end
end
