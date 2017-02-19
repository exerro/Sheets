
local API_URL = "https://api.github.com/repos/Exerro/Sheets/git/trees/%s?recursive=1"
local RAW_URL = "https://raw.githubusercontent.com/Exerro/Sheets/%s/%s"
local NAMED_VERSION_URL = "https://raw.githubusercontent.com/Exerro/Sheets/build-system/versions.txt"
local mode = ...
local HELP = [[
sbs version
 - Controls versions and returns information

Usage
 > version -i|install <version> [--reinstall] [--silent]
 --> installs a version
 --> `--reinstall` to overwrite preinstalled version
 > version remove <version> [--silent]
 --> removes a local version installation
 > version -r|resolve <version> [--silent]
 --> returns the version in semantic version format
 > version -l|list [--local] [--silent]
 --> returns a list of versions
 --> `--local` to only list installed versions
 > version -p|path <version> [--silent]
 --> returns the path to a version
 > version -e|exists <version> [--silent]
 --> returns whether a version is installed
 > version help|-h|--help
 --> displays help

 -> `--silent` to hide terminal output]]

if mode == "-h" or mode == "help" or mode == "--help" then
	return print( HELP )
elseif mode == "-i" then
	mode = "install"
elseif mode == "-r" then
	mode = "resolve"
elseif mode == "-l" then
	mode = "list"
elseif mode == "-p" then
	mode = "path"
elseif mode == "-e" then
	mode = "exists"
end

if mode ~= "install" and mode ~= "remove" and mode ~= "resolve" and mode ~= "list" and mode ~= "path" and mode ~= "exists" then
	if mode then
		return error( "Invalid mode '" .. mode .. "': use `sbs version -h` for help", 0 )
	else
		return error( "Expected mode: use `sbs version -h` for help", 0 )
	end
end

local json_decode = dofile( sheets_global_config:read "install_path" .. "/lib/json.lua" )
local parser = param()

parser:set_param_count( mode == "list" and 0 or 1, mode == "list" and 0 or 1 )
parser:add_section( "silent" ):set_param_count( 0, 0, "silent" )

if mode == "install" then
	parser:add_section( "reinstall" ):set_param_count( 0, 0, "reinstall" )
elseif mode == "list" then
	parser:add_section( "local" ):set_param_count( 0, 0, "local" )
end

local parameters = parser:parse( select( 2, ... ) )

if mode == "list" then
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

local v = parameters[1]

if v:find "^%w+$" and v ~= "develop" then
	local h = http.get( NAMED_VERSION_URL )
	if h then
		local content = h.readAll()
		h.close()

		local match = content:match( v:upper() .. ": ([^\n]+)" )

		if match then
			v = match
		else
			error( "Unable to resolve version '" .. v .. "': invalid version name", 0 )
		end
	else
		error( "Unable to resolve version '" .. v .. "': failed to connect to github", 0 )
	end
elseif v:sub( 1, 1 ) ~= "v" and v ~= "develop" then
	v = "v" .. v
end

local install_path = sheets_global_config:read "install_path" .. "/src/" .. v

if mode == "path" then
	if parameters.silent then
		return install_path
	else
		return print( install_path )
	end
elseif mode == "exists" then
	if parameters.silent then
		return fs.isDir( install_path )
	else
		return print( "Version " .. v .. " is " .. (fs.isDir( install_path ) and "" or "not ") .. "installed" )
	end
elseif mode == "resolve" then
	if parameters.silent then
		return v
	else
		return print( v )
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
	if fs.isDir( install_path ) then
		fs.delete( install_path )

		if not parameters.silent then
			print( "Version " .. v .. " removed" )
		end

		return true
	else
		if not parameters.silent then
			print( "Version " .. v .. " not installed" )
		end

		return false
	end
end
