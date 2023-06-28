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
-- @file        main.lua
--
-- Change Logs:
-- Date           Author       Notes
-- ------------   ----------   -----------------------------------------------
-- 2023-05-27     xqyjlj       initial version
--
import("core.base.option")
import("core.project.project")

function create_project(template, targetname, package)
    if not table.contains(os.dirs(path.join(os.scriptdir(), "templates", "*")),
                          path.join(os.scriptdir(), "templates", template)) then
        raise("unsupport template => %s", template)
    end

    -- get project directory
    local projectdir = path.absolute(option.get("project") or path.join(os.curdir(), targetname))
    if not os.isdir(projectdir) then
        -- make the project directory if not exists
        os.mkdir(projectdir)
    end

    -- xmake.lua exists?
    if os.isfile(path.join(projectdir, "xmake.lua")) and not option.get("force") then
        raise("project (${underline}%s/xmake.lua${reset}) exists!", projectdir)
    end

    -- empty project?
    os.tryrm(path.join(projectdir, ".xmake"))
    if not os.emptydir(projectdir) and not option.get("force") then
        -- otherwise, check whether it is empty
        raise("project directory (${underline}%s${reset}) is not empty!", projectdir)
    end

    os.cd(projectdir)
    local filedirs = {}
    local sourcedir = path.join(os.scriptdir(), "templates", template)

    if os.isdir(sourcedir) then
        for _, filedir in ipairs(os.filedirs(path.join(sourcedir, "*"))) do
            os.cp(filedir, projectdir)
            table.insert(filedirs, path.relative(filedir, sourcedir))
        end
        os.cp(path.join(os.programdir(), "scripts", "gitignore"), path.join(projectdir, ".gitignore"))
        table.insert(filedirs, ".gitignore")
    else
        raise("template(%s): project not found!", templateid)
    end

    -- replace all variables

    local builtinvars = {}
    builtinvars.FAQ = io.readfile(path.join(os.scriptdir(), "faq.lua"))
    builtinvars.TARGETNAME = targetname
    builtinvars.PACKAGE = package

    for _, configfile in ipairs(filedirs) do
        local pattern = "%${(.-)}"
        io.gsub(configfile, "(" .. pattern .. ")", function(_, variable)
            variable = variable:trim()
            local value = builtinvars[variable]
            return type(value) == "function" and value() or value
        end)
    end

    -- trace
    for _, filedir in ipairs(filedirs) do
        if os.isdir(filedir) then
            for _, file in ipairs(os.files(path.join(filedir, "**"))) do
                cprint("  ${green}[+]: ${clear}%s", file)
            end
        else
            cprint("  ${green}[+]: ${clear}%s", filedir)
        end
    end
end

function main()
    local olddir = os.cd(os.workingdir())
    local targetname = option.get("target") or "demo"
    cprint("${bright}create %s ...", targetname) -- trace
    create_project(option.get("template"), targetname, option.get("package"))
    cprint("${color.success}create ok!") -- trace
    os.cd(olddir)
end
