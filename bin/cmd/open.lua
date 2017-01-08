
local parser = param()

parser:set_param_count( 0, 1 )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )

local parameters = parser:parse( ... )

if #parameters == 0 then
	if parameters.silent then
		return sheets_global_config:read "project.open" and {
			name = sheets_global_config:read "project.name";
			path = sheets_global_config:read "project.path";
		} or nil
	else
		if sheets_global_config:read "project.open" then
			print( "Project '" .. sheets_global_config:read "project.name" .. "' @ '" .. sheets_global_config:read "project.path" .. "'" )
		else
			print "No project open"
		end
	end
else
	local name = parameters[1]
	local path = shell.resolve( name )

	if fs.isDir( path ) and fs.exists( path .. "/.project_conf.txt" ) then
		local conf = config.open( path .. "/.project_conf.txt" )

		name = conf:read "name"

		sheets_global_config:write( "project.name", name )
		sheets_global_config:write( "project.path", path )
		sheets_global_config:write( "project.open", true )

		if not parameters.silent then
			print( "Opened project '" .. name .. "'" )
		end
	else
		error( "Failed to find project '" .. name .. "'", 0 )
	end
end