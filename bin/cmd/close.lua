
local h = ...
local HELP = [[
sbs close
 - Closes the current open project

Usage
 > close [--silent]
 --> close the project
 --> `--silent` to hide terminal output
 > close help|-h|--help
 --> display help]]

if h == "help" or h == "-h" or h == "--help" then
	print( HELP )
end

if sheets_global_config:read "project.open" then
	sheets_global_config:write( "project.open", false )

	if h ~= "--silent" then
		print( "Closed project '" .. sheets_global_config:read "project.name" .. "'" )
	else
		return sheets_global_config:read "project.name"
	end
elseif h ~= "--silent" then
	return print "No project to close"
end
