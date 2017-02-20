
local args = { ... }
local command = table.remove( args, 1 )
local commands_lookup = {}
local env = setmetatable( {}, { __index = _ENV or getfenv() } )
local command_names
local THIS_PATH, LIB_PATH

local function load_file( path, name )
	local h = fs.open( path, "r" )

	if h then
		local content = h.readAll()
		h.close()

		local f, err = (load or loadstring)( content, name, nil, env )

		if not f then
			error( err, 0 )
		elseif setfenv then
			setfenv( f, env )
		end

		return f
	end

	return error( "failed to open file '" .. path .. "'", 0 )
end

local function load_cmd( name )
	return load_file( THIS_PATH .. "/cmd/" .. name .. ".lua", name )
end

do
	local h = fs.open( ".sheets_conf.txt", "r" )
	if h then
		local content, data = h.readAll()

		h.close()
		data = textutils.unserialize( content )
		THIS_PATH = type( data ) == "table"
		        and type( data.install_path ) == "string"
				and data.install_path .. "/bin"
	end

	if not THIS_PATH then
		THIS_PATH = (shell.getRunningProgram():find "/sbs.lua$" or shell.getRunningProgram() == "sbs.lua")
	            and fs.isDir( (shell.getRunningProgram():match ".+/" or "/") .. "cmd" )
				and shell.getRunningProgram():match "(.+)/"
				 or "sheets/bin"
	end

	if not fs.isDir( THIS_PATH ) or not fs.exists( THIS_PATH .. "/sbs.lua" ) then
		return error( "Failed to find Sheets installation directory, please repair .sheets_conf.txt", 0 )
	end
end

LIB_PATH = THIS_PATH:gsub( "bin$", "lib" )
command_names = fs.list( THIS_PATH .. "/cmd" )

do
	local ok, data = pcall( load_file( LIB_PATH .. "/param.lua" ) )

	if ok then
		env["param"] = data
	else
		error( data, 0 )
	end
end

do
	local ok, data = pcall( load_file( LIB_PATH .. "/config.lua" ) )

	if ok then
		env["config"] = data
		env["sheets_global_config"] = env.config.open ".sheets_conf.txt" :autosave()
	else
		error( data, 0 )
	end
end

for i = 1, #command_names do
	local name = command_names[i]:gsub( "%.lua$", "" )
	commands_lookup[name] = true
	env[name] = function( ... )
		env[name] = load_cmd( name )
		return env[name]( ... )
	end
end

if commands_lookup[command] then
	env[command]( unpack( args ) )
elseif type( command ) == "string" then
	return error( "no such command '" .. command .. "'", 0 )
else
	return error( "expected command for arg 1", 0 )
end
