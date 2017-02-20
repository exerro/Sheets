
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
local preprocess = dofile( sheets_global_config:read "install_path" .. "/lib/preprocess.lua" )

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

for k, v in pairs( conf:read "flags" ) do
	flags[k] = v
end

for i = 1, #parameters.flags do
	local name, value = parameters.flags[i], true

	if name:find "=" then
		name, value = name:match "(.*)=(.*)"
	end

	flags[name] = value ~= "false" and (value == "true" or value)
end

if not rebuild then
	rebuild = not fs.exists( project .. "/.sheets_debug/sheets.lua" )
	       or not comp_sheets_flags( flags, debug_conf:read "flags" )
		   or debug_conf:read "version" ~= v
end

rebuild = false

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

	local state = preprocess.create_state( version( "path", v, "--silent" ) )

	state.microminify = parameters.minify

	local lines = preprocess.process_file( "sheets", state )
	local h = fs.open( project .. "/.sheets_debug/sheets.lua", "w" )

	if h then
		h.write( output )
		h.close()
	else
		error( "failed to write build file", 0 )
	end
end

local to_include = conf:read "files"
local lines = {}

 -- lines[1] = " -- @import /" .. project .. "/.sheets_debug/sheets.out"
lines[1] = " -- @import /" .. version( "path", v, "--silent" ) .. "/sheets"

for i = 1, #to_include do
	lines[i + 1] = " -- @include " .. to_include[i]
end

local state = preprocess.create_state( project )

state.microminify = parameters.minify

for k, v in pairs( flags ) do
	state.environment[k] = v
end

local lines = preprocess.process_content( table.concat( lines, "\n" ), "sbs debug", state )
local content = preprocess.compile_lines( lines, state )
local f, err = loadstring( content, "sbs debug" )
local ok, err = pcall( f, unpack( parameters ) )

if not ok then
	return error( err, 0 )
end
