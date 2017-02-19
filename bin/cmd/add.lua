
local mode = ...
local parser = param()
local HELP = [[
sbs add
 - Adds a file or flag to the current open project

Usage
 > add file <filename> [--silent]
 --> add a file to the include list
 --> '--silent' to hide terminal output
 > add flag <flag> [--silent]
 --> add a flag to the flag list
 --> '--silent' to hide terminal output
 > add help|-h|--help
 --> display help

File names
----------
File names should be relative to the project path and use dot notation, `directory.file` rather than `directory/file.lua`.]]

if mode == "--help" or mode == "-h" or mode == "help" then
	return print( HELP )
elseif mode ~= "file" and mode ~= "flag" then
	if mode then
		return error( "Invalid mode '" .. mode .. "': use 'sbs add -h' for help", 0 )
	else
		return error( "Expected mode: use `sbs add -h` for help", 0 )
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
				print( "File '" .. data .. "' already added" )
			end
			return false
		end
	end

	files[#files + 1] = data
	conf:write( "files", files )
	conf:save()

	if not parameters.silent then
		print( "Added file '" .. data .. "'" )
	end

	return true
elseif mode == "flag" then
	local flags = conf:read "flags"

	flags[data] = true
	conf:write( "flags", flags )
	conf:save()

	if not parameters.silent then
		print( "Added flag '" .. data .. "'" )
	end
end
