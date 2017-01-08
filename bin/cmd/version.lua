
local NAMED_VERSION_URL = "https://raw.githubusercontent.com/Exerro/Sheets/master/versions.txt"

local parser = param()

parser:set_param_count( 1, 1 )
parser:add_section( "installed" ):set_param_count( 0, 0, "installed" )
parser:add_section( "resolve" ):set_param_count( 0, 0, "resolve" )
parser:add_section( "silent" ):set_param_count( 0, 0, "silent" )
parser:add_section( "path" ):set_param_count( 0, 0, "path" )

local parameters = parser:parse( ... )

local v = parameters[1]

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

if parameters.path then
	if parameters.silent then
		return install_path
	else
		print( install_path )
	end
elseif parameters.installed then
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
elseif not parameters.silent then
	print( "Sheets version " .. v )

	if fs.isDir( install_path ) then
		print( "Installed at " .. install_path )
	else
		print "Not installed"
	end
end
