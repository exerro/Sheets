
local args = { ... }
local command = table.remove( args, 1 )

local THIS_PATH = "sheets/bin"

if (shell.getRunningProgram():find "/spm.lua$" or shell.getRunningProgram() == "spm.lua")
and fs.isDir( (shell.getRunningProgram():match ".+/" or "/") .. "cmd" ) then
	THIS_PATH = shell.getRunningProgram():match "(.+)/" or ""
end

local LIB_PATH = THIS_PATH:gsub( "bin$", "lib" )

local env = setmetatable( {}, { __index = _ENV or getfenv() } )
local command_names = fs.list( THIS_PATH .. "/cmd" )

local function load_cmd( name )
	local h = fs.open( THIS_PATH .. "/cmd/" .. name .. ".lua", "r" )
	if h then
		local content = h.readAll()
		h.close()

		local f, err = (load or loadstring)( content, name, nil, env )

		if not f then
			error( err, 0 )
		end

		if setfenv then
			setfenv( f, env )
		end

		return f
	else
		return error( "command '" .. name .. "' cannot be opened and executed", 0 )
	end
end

local h = fs.open( LIB_PATH .. "/param.lua", "r" )
if h then
	local content = h.readAll()
	h.close()

	local ok, data = pcall( assert( (load or loadstring)( content, "param.lua" ) ) )

	if ok then
		env["param"] = data
	else
		error( data, 0 )
	end
else
	error( "failed to open parameter parser", 0 )
end

local h = fs.open( LIB_PATH .. "/config.lua", "r" )
if h then
	local content = h.readAll()
	h.close()

	local ok, data = pcall( assert( (load or loadstring)( content, "config.lua" ) ) )

	if ok then
		env["config"] = data
		env["sheets_global_config"] = env.config.open ".sheets_conf.txt" :autosave()
	else
		error( data, 0 )
	end
else
	error( "failed to open config manager", 0 )
end

for i = 1, #command_names do
	local name = command_names[i]:gsub( "%.lua$", "" )
	env[name] = function( ... )
		env[name] = load_cmd( name )
		return env[name]( ... )
	end
end

if env[command] then
	env[command]( unpack( args ) )
elseif type( command ) == "string" then
	return error( "no such command '" .. command .. "'", 0 )
else
	return error( "expected command for arg 1", 0 )
end
