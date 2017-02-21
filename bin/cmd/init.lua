
local h = ...
local parser = param()
local HELP = [[
sbs init
 - Initialises a new project

Usage
 > init <project name> [--open] [--force] [--version <version>] [--silent]
 --> '--open' to open the project after creation
 --> '--force' to overwrite an existing project
 --> '--version' to specify version, defaults to 'stable'
 --> '--silent' to hide terminal output
 > init help|-h|--help
 --> display help

Project path format
-------------------
Should be a relative path e.g. `directory/project_folder`.

Version format
--------------
Should be 'develop', 'stable' or 'vMAJOR.MINOR.PATCH'.]]

if h == "-h" or h == "help" or h == "--help" then
	return print( HELP )
end

parser:set_param_count( 1, 1 )
parser:add_section( "open" ):set_param_count( 0, 0, "open" )
parser:add_section( "force" ):set_param_count( 0, 0, "force" )
parser:add_section( "version" ):set_param_count( 0, 1, "version" )
parser:add_section( "silent" ):set_param_count( 0, 0, "silent" )

parser:set_param_modifier( function( v )
	return version( "resolve", v, "--silent" )
end, "version" )

parser:set_param_validator( function( v )
	if not v:find "^v%d+%.%d+%.%d+$" and v ~= "develop" then
		return false, "expected version format of vMAJOR.MINOR.PATCH"
	end
	return true
end, "version" )

local parameters = parser:parse( ... )
local name_raw = parameters[1]:gsub( "%.", "/" )
local name = name_raw:gsub ".+/", ""
local path = shell.resolve( name_raw )
local ver = parameters.version or version( "resolve", "stable", "--silent" )

if fs.exists( path .. "/.project_conf.txt" ) then
	if parameters.force then
		fs.delete( path .. "/.project_conf.txt" )
		fs.delete( path .. "/.sheets_debug" )
	else
		if parameters.silent then
			return false
		else
			return error( "Directory '" .. name .. "' already exists, use --force to overwrite", 0 )
		end
	end
end

if not parameters.silent then
	print( "Initialising " .. name .. " @ " .. path )
	print( "Using Sheets " .. ver )
end

if not version( "exists", ver, "--silent" ) then
	version( "install", ver )
end

fs.makeDir( path )
fs.makeDir( path .. "/.sheets_debug" )

local conf = config.open( path .. "/.project_conf.txt" )

conf:write( "name", name )
conf:write( "author", "anonymous" )
conf:write( "version", "stable" )
conf:write( "sheets_version", ver )
conf:write( "files", {} )
conf:write( "flags.SHEETS_CORE_ELEMENTS", true )
conf:write( "flags.SHEETS_THREADING", true )
conf:write( "flags.SHEETS_LOWRES", true )
conf:write( "flags.SHEETS_SML", false )
conf:close()

if parameters.open then
	open( parameters[1] )
end
