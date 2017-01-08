
local API_URL = "https://api.github.com/repos/Exerro/Sheets/git/trees/%s?recursive=1"
local RAW_URL = "https://raw.githubusercontent.com/Exerro/Sheets/%s/%s"
local NAMED_VERSION_URL = "https://raw.githubusercontent.com/Exerro/Sheets/build-system/versions.txt"

local json_decode = dofile( sheets_global_config:read "install_path" .. "/lib/json.lua" )

local parser = param()

parser:set_param_count( 2, 2 )
parser:add_section( "silent" ):set_param_count( 0, 0, "silent" )
parser:add_section( "reinstall" ):set_param_count( 0, 0, "reinstall" )

local parameters = parser:parse( ... )

local mode = parameters[1]
local v = parameters[2]

if mode ~= "install" and parameters.reinstall then
	return error( "Unexpected --reinstall in '" .. mode .. "' mode", 0 )
end

if v:find "^%w+$" then
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
elseif v:sub( 1, 1 ) ~= "v" then
	v = "v" .. v
end

local install_path = sheets_global_config:read "install_path" .. "/src/" .. v

if mode == "path" then
	if parameters.silent then
		return install_path
	else
		print( install_path )
	end
elseif mode == "exists" then
	if parameters.silent then
		return fs.isDir( install_path )
	else
		print( "Version " .. v .. " is " .. (fs.isDir( install_path ) and "" or "not ") .. "installed" )
	end
elseif mode == "resolve" then
	if parameters.silent then
		return v
	else
		print( v )
	end
elseif mode == "status" then
	print( "Sheets version " .. v )

	if fs.isDir( install_path ) then
		print( "Installed at " .. install_path )
	else
		print "Not installed"
	end
elseif mode == "install" then
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
elseif mode == "remove" then
	fs.delete( install_path )

	if not parameters.silent then
		print( "Version " .. v .. " removed" )
	end
else
	error( "unknown mode '" .. mode .. "'" )
end
