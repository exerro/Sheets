
local parser = param()

parser:set_param_count( 1, 1 )
parser:add_section( "open" ):set_param_count( 0, 0, "open" )
parser:add_section( "force" ):set_param_count( 0, 0, "force" )
parser:add_section( "version" ):set_param_count( 0, 1, "version" )
parser:add_section( "silent" ):set_param_count( 0, 0, "silent" )

local function resolve_version( v )
	return version( v, "--resolve", "--silent" )
end

parser:set_param_modifier( function( v )
	return resolve_version( v )
end, "version" )

parser:set_param_validator( function( v )
	if not v:find "^v%d+%.%d+%.%d+$" then
		return false, "expected version format of vMAJOR.MINOR.PATCH"
	end
	return true
end, "version" )

local parameters = parser:parse( ... )
local name = parameters[1]
local path = shell.resolve( name )
local ver = parameters.version or resolve_version "stable"

if fs.exists( path .. "/.project_conf.txt" ) then
	if parameters.force then
		fs.delete( path .. "/.project_conf.txt" )
		fs.delete( path .. "/.sheets_debug" )
	else
		if parameters.silent then
			return false
		else
			return print( "Directory '" .. name .. "' already exists, use --force to overwrite" )
		end
	end
end

if not parameters.silent then
	print( "Initialising " .. name .. " @ " .. path )
	print( "Using Sheets " .. ver )
end

if not version( ver, "--installed", "--silent" ) then
	install( ver, "--silent" )
end

fs.makeDir( path )
fs.makeDir( path .. "/.sheets_debug" )

local conf = config.open( path .. "/.project_conf.txt" )

conf:write( "name", name )
conf:write( "author", "anonymous" )
conf:write( "version", "0.0.1" )
conf:write( "sheets_version", ver )
conf:write( "files", {} )
conf:write( "flags.SHEETS_CORE_ELEMENTS", true )
conf:write( "flags.SHEETS_LOWRES", true )
conf:write( "flags.SHEETS_DYNAMIC", true )
conf:write( "flags.SHEETS_PARSING", false )
conf:write( "flags.SHEETS_DYNAMIC_PARSING", false )
conf:write( "flags.SHEETS_MINIFY", false )
conf:write( "flags.SHEETS_SML", false )

conf:close()

if parameters.open then
	open( parameters[1] )
end
