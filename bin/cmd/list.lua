
local mode = ...
local parser = param()
local HELP = [[
sbs list
 - Lists all files or flags in the current open project

Usage
 > list files [--silent]
 --> list all file in the include list
 --> '--silent' to hide terminal output
 > list flags [--silent]
 --> list all flags in the flag list
 --> '--silent' to hide terminal output
 > list help|-h|--help
 --> display help]]

if mode == "--help" or mode == "-h" or mode == "help" then
	return print( HELP )
elseif mode ~= "files" and mode ~= "flags" then
	if mode then
		return error( "Invalid mode '" .. mode .. "': use 'sbs add -h' for help", 0 )
	else
		return error( "Expected mode: use `sbs add -h` for help", 0 )
	end
end

parser:set_param_count( 0, 0 )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )

local parameters = parser:parse( select( 2, ... ) )
local project = sheets_global_config:read "project.open" and sheets_global_config:read "project.path"
local data = parameters[1]
local conf = project and config.open( project .. "/.project_conf.txt" )

if not project then
	return error( "Cannot list '" .. mode .. "': no project open", 0 )
end

if mode == "files" then
	local files = conf:read "files"

	if parameters.silent then
		return files
	else
		for i = 1, #files do
			print( files[i] )
		end
	end
elseif mode == "flags" then
	local flags = conf:read "flags"

	if parameters.silent then
		return flags
	else
		local maxindent = 0

		local function indentrecursive( flags, indent )
			for k, v in pairs( flags ) do
				if type( v ) == "table" then
					indentrecursive( v, indent + 1 )
				else
					maxindent = math.max( maxindent, 2 * indent + #k )
				end
			end
		end

		local function printrecursive( flags, indent )
			for k, v in pairs( flags ) do
				if type( v ) == "table" then
					term.setTextColour( colours.lightGrey )
					term.write( ("  "):rep( indent ) .. k )
					term.setTextColour( colours.grey )
					print " ->"
					printrecursive( v, indent + 1 )
				else
					term.write( ("  "):rep( indent ) )

					if k:find "^SHEETS_" then
						term.setTextColour( colours.lightGrey )
						term.write( "SHEETS_" )
						term.setTextColour( colours.white )
						term.write( k:sub( 8 ) )
					else
						term.setTextColour( colours.white )
						term.write( k )
					end

					term.setTextColour( colours.grey )
					term.write( (" "):rep( maxindent - 2 * indent - #k ) .. " = " )
					term.setTextColour( colours.lightBlue )
					print( textutils.serialize( v ) )
				end
			end
		end

		indentrecursive( flags, 0 )
		printrecursive( flags, 0 )
	end
end
