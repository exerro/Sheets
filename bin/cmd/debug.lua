
local h = ...
local parser = param()
local HELP = [[
sbs debug
 - Builds and runs a project

Usage
 > debug [--flags ...] [--rebuild] [--minify] [--silent]
 --> debug the current project
 --> `--flags` to pass in one-off flags
 --> `--parameters` to pass parameters to the program
 --> `--rebuild` to ignore cached sheets build
 --> `--minify` to minify build
 --> `--silent` to hide terminal output
]]

if h == "-h" or h == "help" or h == "--help" then
	return print( HELP )
end

parser:set_param_count( 0 )
parser:add_section "flags" :set_param_count( 0, nil, "flags" )
parser:add_section "rebuild" :set_param_count( 0, 0, "rebuild" )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )
parser:add_section "minify" :set_param_count( 0, 0, "minify" )

local parameters = parser:parse( ... )
local rebuild = parameters.rebuild
local project = sheets_global_config:read "project.open" and sheets_global_config:read "project.path"
local h = fs.open( sheets_global_config:read "install_path" .. "/amend/amend.lua", "r" )
local amend

if h then
	local content = h.readAll()
	local env = setmetatable( { AMEND_PATH = sheets_global_config:read "install_path" .. "/amend" }, { __index = _ENV or getfenv() } )

	h.close()
	amend = assert( load( content, "amend", nil, env ) )

	if setfenv then
		setfenv( amend, env )
	end
end

if not project then
	return error( "No project to debug", 0 )
end

local function comp_sheets_flags( a, b )
	for k, v in pairs( a ) do
		if b[k] ~= v then return false end
	end
	for k, v in pairs( b ) do
		if a[k] ~= v then return false end
	end
	return true
end

local conf = config.open( project .. "/.project_conf.txt" )
local debug_conf = config.open( project .. "/.sheets_debug/conf.txt" )
local v = version( "resolve", conf:read "sheets_version", "--silent" )
local flags = {}
local flags_serialized = {}

for k, v in pairs( conf:read "flags" ) do
	flags[k] = v
	flags_serialized[#flags_serialized + 1] = "-s"
	flags_serialized[#flags_serialized + 1] = k .. "=" .. textutils.serialize( v )
end

for i = 1, #parameters.flags do
	local name, value = parameters.flags[i], true

	if name:find "=" then
		name, value = name:match "(.+)=(.+)"
	end

	flags[name] = value ~= "false" and (value == "true" or tonumber( value ) or value)
	flags_serialized[#flags_serialized + 1] = "-s"
	flags_serialized[#flags_serialized + 1] = parameters.flags[i]
end

if not rebuild then
	rebuild = not fs.exists( project .. "/.sheets_debug/sheets.pack.lua" )
	       or not comp_sheets_flags( flags, debug_conf:read "flags" )
		   or debug_conf:read "version" ~= v
end

if rebuild then
	if not parameters.silent then
		print( "Rebuilding Sheets " .. v )
	end

	debug_conf:write( "flags", flags )
	debug_conf:write( "version", v )
	debug_conf:save()

	if not version( "exists", v, "--silent" ) then
		version( "install", v, parameters.silent and "--silent" or nil )
	end

	amend( "sheets", "-s", version( "path", v, "--silent" ), "-mp", "-o", project .. "/.sheets_debug/sheets" )
end

local to_include = conf:read "files"
local lines = {}

lines[1] = " -- @import /" .. project .. "/.sheets_debug/sheets.pack"

for i = 1, #to_include do
	lines[i + 1] = " -- @include " .. to_include[i]
end

local file_contents = table.concat( lines, "\n" )
local h = fs.open( project .. "/.sheets_debug/file_includer.lua", "w" )
local content

if h then
	h.write( file_contents )
	h.close()
else
	return error( "failed to write to intermediate file", 0 )
end

fs.delete( project .. "/.sheets_debug/debug.lua" )

if minify then
	amend( "file_includer", "-s", project, "-s", "/" .. project .. "/.sheets_debug/", "-me", "-mm", "-o", project .. "/.sheets_debug/debug", unpack( flags ) )
else
	amend( "file_includer", "-s", project, "-s", "/" .. project .. "/.sheets_debug/", "-me", "-o", project .. "/.sheets_debug/debug", unpack( flags ) )
end

fs.delete( project .. "/.sheets_debug/file_includer.lua" )
h = fs.open( project .. "/.sheets_debug/debug.lua", "r" )

if h then
	content = h.readAll()
	h.close()
	fs.delete( project .. "/.sheets_debug/debug.lua" )
else
	return error( "failed to read debug file", 0 )
end

local f, err = loadstring( content, "sbs debug" )
local ok, err = pcall( f, unpack( parameters ) )

if not ok then
	return error( err, 0 )
end
