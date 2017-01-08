
local parser = param()

parser:set_param_count( 2, 2 )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )

local parameters = parser:parse( ... )
local project = sheets_global_config:read "project.open" and sheets_global_config:read "project.path"
local mode = parameters[1]
local data = parameters[2]
local conf = project and config.open( project .. "/.project_conf.txt" )

if not project then
	return error( "No project open", 0 )
end

if mode == "file" then
	local files = conf:read "files"

	for i = 1, #files do
		if files[i] == data then
			if not parameters.silent then
				print( "File '" .. data .. "' already added" )
			end
			return false
		end
	end

	files[#files + 1] = data
	conf:write( "files", files )
	conf:save()

	if not parameters.silent then
		print( "Added file '" .. data .. "'" )
	end
	return true
elseif mode == "flag" then
	local flags = conf:read "flags"

	flags[data] = true
	conf:write( "flags", flags )
	conf:save()

	if not parameters.silent then
		print( "Added flag '" .. data .. "'" )
	end
end
