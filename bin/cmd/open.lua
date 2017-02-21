
local h = ...
local parser = param()
local HELP = [[
sbs open
 - Opens a project or shows the open project

Usage
 > open <project name> [--silent]
 --> open the project
 --> '--silent' to hide terminal output
 > open [--silent]
 --> return information about the open project
 --> '--silent' to hide terminal output
 > open -h|help|--help
 --> display help

Project path format
-------------------
Should be a relative path e.g. `directory/project_folder`.]]

if h == "-h" or h == "help" or h == "--help" then
	return print( HELP )
end

parser:set_param_count( 0, 1 )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )
parser:add_section "reopen" :set_param_count( 0, 0, "reopen" )

local parameters = parser:parse( ... )

if #parameters == 0 then
	if parameters.reopen then
		if sheets_global_config:read "project.open" then
			if not parameters.silent then
				print "Project already open"
			end

			return true
		end

		if sheets_global_config:read "project.name" then
			sheets_global_config:write( "project.open", true )
		elseif parameters.silent then
			return false
		else
			return error( "No previously open project", 0 )
		end

		if not parameters.silent then
			print( "Re-opened project '" .. sheets_global_config:read "project.name" .. "'" )
		end

		return true
	else
		if parameters.silent then
			return sheets_global_config:read "project.open" and {
				name = sheets_global_config:read "project.name";
				path = sheets_global_config:read "project.path";
			} or nil
		else
			if sheets_global_config:read "project.open" then
				print( "Project '" .. sheets_global_config:read "project.name" .. "' @ '" .. sheets_global_config:read "project.path" .. "'" )
			else
				print "No project open"
			end
		end
	end
else
	if parameters.reopen then
		return error( "Cannot open and reopen a project", 0 )
	end

	local name = parameters[1]
	local path = shell.resolve( name )

	if open "--silent" then
		if path == sheets_global_config:read "project.path" then
			if not parameters.silent then
				print( "Project '" .. sheets_global_config:read "project.name" .. "' is already open" )
			end

			return true
		else
			close( parameters.silent and "--silent" )
		end
	end

	if fs.isDir( path ) and fs.exists( path .. "/.project_conf.txt" ) then
		local conf = config.open( path .. "/.project_conf.txt" )

		name = conf:read "name"

		sheets_global_config:write( "project.name", name )
		sheets_global_config:write( "project.path", path )
		sheets_global_config:write( "project.open", true )

		if not parameters.silent then
			print( "Opened project '" .. name .. "'" )
		end
	else
		return error( "Failed to find project '" .. name .. "'", 0 )
	end
end
