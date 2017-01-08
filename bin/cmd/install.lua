
local API_URL = "https://api.github.com/repos/Exerro/Sheets/git/trees/%s?recursive=1"
local RAW_URL = "https://raw.githubusercontent.com/Exerro/Sheets/%s/%s"

local parser = param()
local json_decode = dofile( sheets_global_config:read "install_path" .. "/lib/json.lua" )

parser:set_param_count( 1, 1 )
parser:add_section( "silent" ):set_param_count( 0, 0, "silent" )
parser:add_section( "reinstall" ):set_param_count( 0, 0, "reinstall" )

local parameters = parser:parse( ... )
local v = version( "--resolve", parameters[1], "--silent" )

if version( "--installed", v, "--silent" ) then
	if parameters.reinstall then
		print( "Reinstalling version " .. v )
		fs.delete( version( "--path", v, "--silent" ) )
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
local local_path = sheets_global_config:read "install_path" .. "/src/" .. v .. "/"

if data.message and data.message:find "API rate limit exceeded" then
	return error( "Out of github API calls", 0 )
end

for i = 1, #data.tree do
	local path = data.tree[i].path
	if data.tree[i].type == "tree" then
		if not parameters.silent then
			print( "Creating tree '" .. path .. "'" )
		end
		fs.makeDir( local_path .. path )
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

		local h = fs.open( local_path .. path, "w" )

		if h then
			h.write( content )
			h.close()
		else
			return error( "Failed to install '" .. path .. "'", 0 )
		end
	end
end
