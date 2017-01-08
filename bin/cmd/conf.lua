
local parser = param()

local function validate( name )
	return function()
		if argdone and argdone ~= name then
			return false, "unexpected --" .. name .. " after --" .. argdone
		end
		argdone = name
		return true
	end, name
end

parser:add_section "silent" :set_param_count( 0, 0, "silent" )
parser:add_section "list" :set_param_count( 0, 0, "list" ):set_param_validator( validate "list" )
parser:add_section "get" :set_param_count( 0, 1, "get" ):set_param_validator( validate "get" )
parser:add_section "set" :set_param_count( 0, 2, "set" ):set_param_validator( validate "set" )

local parameters = parser:parse( ... )

local project = sheets_global_config:read "project.open" and sheets_global_config:read "project.path"

if not project then
	return error( "No open project", 0 )
end

local project_conf = config.open( project .. "/.project_conf.txt" )

if parameters.list then
	if parameters.silent then
		return project_conf
	else
		for k, v in pairs( project_conf.data ) do
			print( k )
		end
	end
elseif parameters.get then
	if parameters.silent then
		return project_conf:read( parameters.get )
	else
		print( textutils.serialize( project_conf:read( parameters.get ) ) )
	end
elseif parameters.set then
	local value = parameters.set[2]

	if value == "true" or value == "false" then
		value = value == "true"
	end

	project_conf:write( parameters.set[1], value )
	project_conf:save()

	if not parameters.silent then
		print( "Set index '" .. parameters.set[1] .. "' to '" .. parameters.set[2] .. "'" )
	end
end

-- sbs config --get blah
-- sbs config --list
-- sbs config --set blah value
