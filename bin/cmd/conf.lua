
local mode = ...

if mode == "-l" then
	mode = "list"
elseif mode == "-g" or mode == "read" or mode == "-r" then
	mode = "get"
elseif mode == "-s" or mode == "write" or mode == "w" then
	mode = "set"
end

local len = mode == "set" and 2 or mode == "get" and 1 or 0
local parser = param()
local HELP = [[
sbs conf
 - Allows modification of the current project config

Usage
 > conf list|-l [--silent]
 --> list all config options
 --> '--silent' to hide terminal output
 > conf get|-g|read|-r <key> [--silent]
 --> return a config key
 --> '--silent' to hide terminal output
 > conf set|-s|write|-w <key> [value] [--silent]
 --> set a config key
 --> value defaults to true
 --> '--silent' to hide terminal output
 > conf help|-h|--help
 --> display help]]

if mode == "help" or mode == "-h" or mode == "--help" then
	return print( HELP )
elseif mode ~= "set" and mode ~= "get" and mode ~= "list" then
	if mode then
		return error( "Invalid mode '" .. mode .. "': use 'sbs conf -h' for help", 0 )
	else
		return error( "Expected mode: use `sbs conf -h` for help", 0 )
	end
end

local function validate( name )
	return function()
		if argdone and argdone ~= name then
			return false, "unexpected --" .. name .. " after --" .. argdone
		end
		argdone = name
		return true
	end, name
end

parser:add_section "silent" :set_param_count( 0, 0, "silent" )
parser:set_param_count( mode == "set" and 1 or len, len )

local parameters = parser:parse( select( 2, ... ) )
local project = sheets_global_config:read "project.open" and sheets_global_config:read "project.path"
local project_conf = project and config.open( project .. "/.project_conf.txt" )

if not project then
	return error( "Cannot edit config: no open project", 0 )
end

if mode == "list" then
	if parameters.silent then
		return project_conf.data
	else
		for k, v in pairs( project_conf.data ) do
			print( k )
		end
	end
elseif mode == "get" then
	if parameters.silent then
		return project_conf:read( parameters[1] )
	else
		print( textutils.serialize( project_conf:read( parameters[1] ) ) )
	end
elseif mode == "set" then
	local value = parameters[2] == nil and "true" or parameters[2]

	project_conf:write( parameters[1], value ~= "false" and (value == "true" or tonumber( value ) or value) )
	project_conf:save()

	if not parameters.silent then
		print( "Set index '" .. parameters[1] .. "' to '" .. parameters[2] .. "'" )
	end
end
