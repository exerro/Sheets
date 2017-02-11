
local API_URL = "https://api.github.com/repos/Exerro/Sheets/git/trees/%s?recursive=1"
local RAW_URL = "https://raw.githubusercontent.com/Exerro/Sheets/%s/%s"
local NAMED_VERSION_URL = "https://raw.githubusercontent.com/Exerro/Sheets/build-system/versions.txt"

local json_decode = dofile( sheets_global_config:read "install_path" .. "/lib/json.lua" )

local parser = param()

local argdone

local function validate( name )
	return function()
		if argdone then
			return false, "unexpected --" .. name .. " after --" .. argdone
		end
		argdone = name
		return true
	end, name
end

parser:set_param_count( 0, 0 )
parser:add_section( "reinstall" ):set_param_count( 0, 0, "reinstall" ):set_param_validator( function()
	return argdone == "install", "unexpected --reinstall" .. (argdone and " after --" .. argdone or " before --install")
end, "reinstall" )
parser:add_section( "local" ):set_param_count( 0, 0, "local" ):set_param_validator( function()
	return argdone == "list", "unexpected --local" .. (argdone and " after --" .. argdone or " before --list")
end, "local" )
parser:add_section( "silent" ):set_param_count( 0, 0, "silent" )
parser:add_section( "path" ):set_param_count( 0, 1, "path" ):set_param_validator( validate "path" )
parser:add_section( "exists" ):set_param_count( 0, 1, "exists" ):set_param_validator( validate "exists" )
parser:add_section( "status" ):set_param_count( 0, 1, "status" ):set_param_validator( validate "status" )
parser:add_section( "install" ):set_param_count( 0, 1, "install" ):set_param_validator( validate "install" )
parser:add_section( "remove" ):set_param_count( 0, 1, "remove" ):set_param_validator( validate "remove" )
parser:add_section( "resolve" ):set_param_count( 0, 1, "resolve" ):set_param_validator( validate "resolve" )
parser:add_section( "list" ):set_param_count( 0, 0, "list" ):set_param_validator( validate "list" )

local parameters = parser:parse( ... )

if parameters.list then
	local files = fs.list( sheets_global_config:read "install_path" .. "/src" )

	if not parameters["local"] then
		local files_lookup = {}
		local h, content = http.get "https://api.github.com/repos/Exerro/Sheets/branches", "[]"

		if h then
			content = h.readAll()
			h.close()
		end

		local data = json_decode( content )

		if data.message and data.message:find "API rate limit exceeded" then
			return error( "Out of github API calls", 0 )
		end

		files.remote = {}

		for i = 1, #files do
			files_lookup[files[i]] = true
		end

		for i = 1, #data do
			if not files_lookup[data[i].name] and data[i].name:sub( 1, 1 ) == "v" then
				files.remote[#files.remote + 1] = data[i].name
			end
		end
	end

	if parameters.silent then
		return files
	else
		for i = 1, #files do
			print( files[i] )
		end

		if files.remote then
			term.setTextColour( colours.grey )

			for i = 1, #files.remote do
				print( files.remote[i] )
			end
		end

		return
	end
end

local v = parameters.path or parameters.exists or parameters.resolve or parameters.status or parameters.install or parameters.remove

if v:find "^%w+$" and v ~= "develop" then
	local h = http.get( NAMED_VERSION_URL )
	if h then
		local content = h.readAll()
		h.close()

		local match = content:match( v:upper() .. ": ([^\n]+)" )

		if match then
			v = match
		else
			error( "unable to resolve version '" .. v .. "': invalid version name", 0 )
		end
	else
		error( "unable to resolve version '" .. v .. "': failed to connect to github", 0 )
	end
elseif v:sub( 1, 1 ) ~= "v" and v ~= "develop" then
	v = "v" .. v
end

local install_path = sheets_global_config:read "install_path" .. "/src/" .. v

if parameters.path then
	if parameters.silent then
		return install_path
	else
		print( install_path )
	end
elseif parameters.exists then
	if parameters.silent then
		return fs.isDir( install_path )
	else
		print( "Version " .. v .. " is " .. (fs.isDir( install_path ) and "" or "not ") .. "installed" )
	end
elseif parameters.resolve then
	if parameters.silent then
		return v
	else
		print( v )
	end
elseif parameters.status then
	print( "Sheets version " .. v )

	if fs.isDir( install_path ) then
		print( "Installed at " .. install_path )
	else
		print "Not installed"
	end
elseif parameters.install then
	if fs.isDir( install_path ) then
		if parameters.reinstall then
			if not parameters.silent then
				print( "Reinstalling version " .. v )
			end
			fs.delete( install_path )
		else
			if not parameters.silent then
				print( "Version " .. v .. " already installed" )
			end
			return true
		end
	end

	local h, content = http.get( API_URL:format( v ) )

	if h then
		content = h.readAll()
		h.close()
	else
		return error( "Failed to fetch file list", 0 )
	end

	local data = json_decode( content )

	if data.message and data.message:find "API rate limit exceeded" then
		return error( "Out of github API calls", 0 )
	end

	for i = 1, #data.tree do
		local path = data.tree[i].path
		if data.tree[i].type == "tree" then
			if not parameters.silent then
				print( "Creating tree '" .. path .. "'" )
			end
			fs.makeDir( install_path .. "/" .. path )
		elseif data.tree[i].type == "blob" then
			if not parameters.silent then
				print( "Downloading file '" .. path .. "'" )
			end

			local h, content = http.get( RAW_URL:format( v, path ) )

			if h then
				content = h.readAll()
				h.close()
			else
				return error( "Failed to download '" .. path .. "'", 0 )
			end

			local h = fs.open( install_path .. "/" .. path, "w" )

			if h then
				h.write( content )
				h.close()
			else
				return error( "Failed to install '" .. path .. "'", 0 )
			end
		end
	end
elseif parameters.remove then
	fs.delete( install_path )

	if not parameters.silent then
		print( "Version " .. v .. " removed" )
	end
else
	error( "unknown mode '" .. mode .. "'" )
end
