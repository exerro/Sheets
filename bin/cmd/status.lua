
local parser = param()

parser:set_param_count( 0, 0 )
parser:add_section "silent" :set_param_count( 0, 0, "silent" )

local parameters = parser:parse( ... )

local install_path = sheets_global_config:read "install_path"
local project_open = sheets_global_config:read "project.open"
local project_name = project_open and sheets_global_config:read "project.name" or nil
local project_path = project_open and sheets_global_config:read "project.path" or nil
local project_conf = project_open and config.open( project_path .. "/.project_conf.txt" )

if parameters.silent then
	local data = {}

	data.install_path = install_path
	data.project_open = project_open
	data.project_name = project_name
	data.project_path = project_path

	data.installed_versions = version( "--list", "--local", "--silent" )

	if  data.project_path then
		data.project_version        = project_conf:read "version"
		data.project_author         = project_conf:read "author"
		data.project_sheets_version = project_conf:read "sheets_version"
		data.project_files          = project_conf:read "files"
	end

	return data
else
	print( "Installed under '" .. install_path .. "'\n" )

	if project_open then
		local files = project_conf:read "files"

		print( "Project '" .. project_name .. "' @ " .. project_path )
		term.setTextColour( colours.lightGrey )
		print( "  Version: v" .. project_conf:read "version" )
		print( "  Author: " .. project_conf:read "author" )
		print( "  Sheets version: " .. project_conf:read "sheets_version" )
		print  "  Main files:"
		term.setTextColour( colours.lightBlue )

		for i = 1, #files do
			print( "    " .. files[i] )
		end

		print ""
		term.setTextColour( colours.white )
	else
		print "No project open\n"
	end

	local versions = version( "--list", "--local", "--silent" )

	if #versions > 0 then
		print "Installed Sheets versions:"
		term.setTextColour( colours.lightGrey )

		for i = 1, #versions do
			print( "  " .. versions[i] )
		end
	else
		print "No installed Sheets versions"
	end
end

--[[
sbs status

	Project 'thing'
]]
