
local command = ...

local COMMANDS_HELP = [[
Project switching
 > init - creates a new project
 > open - opens a project
 > close - closes the current project

Project management
 > add - adds files/flags to current project
 > remove - removes files/flags from current project
 > conf - modifies the current project's config
 > debug - runs a project

Sheets help
 > status - returns project and sheets status
 > version - manages versions and returns information
 > help - returns help]]
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
