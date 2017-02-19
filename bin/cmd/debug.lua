
local parser = param()

local sheets_env_setter = [[
local t = {}
for k, v in pairs( _ENV ) do
	t[k] = v
end
t.sheets = sheets
setmetatable( t, getmetatable( _ENV ) )
local _ENV = t
]]

parser:set_param_count( 0 )
parser:add_section "parameters" :set_param_count( 0, nil, "parameters" )
parser:add_section "rebuild" :set_param_count( 0, 0, "rebuild" )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )
parser:add_section "nominify" :set_param_count( 0, 0, "nominify" )

local parameters = parser:parse( ... )
local rebuild = parameters.rebuild
local project = sheets_global_config:read "project.open" and sheets_global_config:read "project.path"
local builder

if not project then
	return error( "No project to debug", 0 )
end

local function compt( a, b )
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
local v = version( "--resolve", conf:read "sheets_version", "--silent" )
local flags = {}

for k, v in pairs( conf:read "flags" ) do
	flags[k] = v
end

flags.SHEETS_MINIFY = false
flags.SHEETS_WRAP = true
flags.SHEETS_EXTERNAL = false

for i = 1, #parameters do
	local name, value = parameters[i], true
	if name:find "=" then
		name, value = name:match "(.*)=(.*)"
	end
	flags[name] = value ~= "false" and (value == "true" or value)
end

if not rebuild then
	rebuild = not fs.exists( project .. "/.sheets_debug/sheets.lua" )
		or debug_conf:read "version" ~= v
		or not compt( flags, debug_conf:read "flags" )
end

local h = fs.open( sheets_global_config:read "install_path" .. "/lib/build.lua", "r" )

if h then
	local content = h.readAll()
	h.close()

	builder = assert( (load or loadstring)( content, "build.lua", nil, _ENV or getfenv() ) )()

	if setfenv then
		setfenv( builder, getfenv() )
	end
else
	return error( "failed to open build.lua", 0 )
end

if rebuild then
	if not parameters.silent then
		print( "Rebuilding Sheets " .. v )
	end

	debug_conf:write( "flags", flags )
	debug_conf:write( "version", v )
	debug_conf:save()

	flags.SHEETS_MINIFY = not parameters.nominify and false

	if not version( "--exists", v, "--silent" ) then
		version( "--install", v, parameters.silent and "--silent" or nil )
	end

	local output = builder( { sheets_global_config:read "install_path" .. "/src/" .. v }, "sheets", flags )
	local h = fs.open( project .. "/.sheets_debug/sheets.lua", "w" )

	flags.SHEETS_MINIFY = false

	if h then
		h.write( output )
		h.close()
	else
		error( "failed to write build file", 0 )
	end
end

local h = fs.open( project .. "/.sheets_debug/file_includer.lua", "w" )
local to_include = conf:read "files"

if h then
	if not parameters.silent then
		print "Generating build file"
	end

	h.writeLine( " -- @include_raw /" .. version( "--path", v, "--silent" ) .. "/constants" )
	h.writeLine( sheets_env_setter )

	for i = 1, #to_include do
		h.writeLine( " -- @require_raw /" .. project .. "/" .. to_include[i] )
	end

	h.close()
else
	return error( "failed to generate build files", 0 )
end

if not parameters.silent then
	print "Executing build file"
end

local h, content = fs.open( project .. "/.sheets_debug/sheets.lua", "r" )

if h then
	content = h.readAll() .. "\n"
	h.close()
else
	return error( "failed to read build file", 0 )
end

local build = builder( { project }, "/" .. project .. "/.sheets_debug/file_includer", flags )
local f, err = (load or loadstring)( content .. build, conf:read "name" .. " [DEBUG]", nil, _ENV or getfenv() )

if not f then
	error( err, 0 )
end

if setfenv then
	setfenv( f, getfenv() )
end

local ok, err = pcall( f, parameters.parameters )

if not ok then
	return error( err, 0 )
end
