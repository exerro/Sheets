
local mode = ...
local parser = param()
local HELP = [[
sbs remove
 - Removes a file or flag from the current open project

Usage
 > remove file <filename> [--silent]
 --> remove a file from the include list
 --> '--silent' to hide terminal output
 > remove flag <flag> [--silent]
 --> remove a flag from the flag list
 --> '--silent' to hide terminal output
 > remove help|-h|--help
 --> display help

File names
----------
File names should be relative to the project path and use dot notation, `directory.file` rather than `directory/file.lua`.]]

if mode == "--help" or mode == "-h" or mode == "help" then
	return print( HELP )
elseif mode ~= "file" and mode ~= "flag" then
	if mode then
		return error( "Invalid mode '" .. mode .. "': use 'sbs remove -h' for help", 0 )
	else
		return error( "Expected mode: use `sbs remove -h` for help", 0 )
	end
end

parser:set_param_count( 1, 1 )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )

local parameters = parser:parse( select( 2, ... ) )
local project = sheets_global_config:read "project.open" and sheets_global_config:read "project.path"
local data = parameters[1]
local conf = project and config.open( project .. "/.project_conf.txt" )

if not project then
	return error( "Cannot add '" .. mode .. "': no project open", 0 )
end

if mode == "file" then
	local files = conf:read "files"

	for i = 1, #files do
		if files[i] == data then
			if not parameters.silent then
				print( "File '" .. data .. "' removed" )
			end

			table.remove( files, i )
			conf:write( "files", files )
			conf:save()

			return true
		end
	end

	if not parameters.silent then
		return print( "File '" .. data .. "' not found" )
	end

	return false
elseif mode == "flag" then
	local flags = conf:read "flags"

	flags[data] = nil
	conf:write( "flags", flags )
	conf:save()

	if not parameters.silent then
		print( "Removed flag '" .. data .. "'" )
	end
end
