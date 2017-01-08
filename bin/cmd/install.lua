
local SHEETS_URL = "https://raw.githubusercontent.com/Exerro/Sheets/master/src/"

local parser = param()

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
