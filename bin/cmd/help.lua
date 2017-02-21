
local command = ...

local COMMANDS_HELP = [[
Project switching
 > init - create a new project
 > open - open a project
 > close - close the current project

Project management
 > add - add files/flags to current project
 > remove - remove files/flags from current project
 > list - list files/flags in current project
 > conf - modify the current project's config
 > debug - run a project

Sheets help
 > status - return project and sheets status
 > version - manage versions and returns information
 > help - show help]]
local GENERIC_HELP = [[
sbs help
 - Returns help

Usage
 > sbs help <command>
 --> Returns help for a given command
 > sbs help commands
 --> Returns a command list
 > sbs help
 --> Returns general help
]]

if command == "commands" then
	return print( COMMANDS_HELP )
elseif command then
	(_ENV or getfenv())[command] "-h"
else
	return print( GENERIC_HELP )
end
