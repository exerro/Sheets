
local path = ... or "sheets"
local URL = "https://raw.githubusercontent.com/Exerro/Sheets/build-system/"
local CONFIG_TEXT = [[
{
	install_path = "%s";
	project = { open = false }
}]]
local PATCH_INFO = "The patch will modify startup to "
.. "alias `sbs` to %s/bin/sbs.lua, so you don't need "
.. "to type in the long path name every time"

if fs.exists( path ) then
	print( "The path " .. path .. " already exists, overwrite? (y/N)" )
	local event, key
	repeat
		event, key = os.pullEventRaw()
	until event == "key"

	if key == keys.y then
		fs.delete( path )
	else
		print "Installation cancelled"
		return
	end
end

local files = {
	"bin/sbs.lua";
	"bin/cmd/add.lua";
	"bin/cmd/close.lua";
	"bin/cmd/debug.lua";
	"bin/cmd/init.lua";
	"bin/cmd/install.lua";
	"bin/cmd/open.lua";
	"bin/cmd/remove.lua";
	"bin/cmd/version.lua";
	"lib/build.lua";
	"lib/config.lua";
	"lib/minify.lua";
	"lib/param.lua";
	"lib/preprocessor.lua";
	"res/instructions/conditional.lua";
	"res/instructions/console.lua";
	"res/instructions/define.lua";
	"res/instructions/include.lua";
	"versions.txt";
}

fs.makeDir( path )

for i = 1, #files do
	local h, content = http.get( URL .. files[i] )

	if h then
		content = h.readAll()
		h.close()
	else
		error( "Installation failed: failed to download file '" .. files[i] .. "'", 0 )
	end

	local h = fs.open( path .. "/" .. files[i], "w" )

	if h then
		h.write( content )
		h.close()
	else
		error( "Installation failed: failed to install file '" .. files[i] .. "'", 0 )
	end
end

local h = fs.open( ".sheets_conf.txt", "w" )

if h then
	h.write( CONFIG_TEXT:format( path ) )
	h.close()
else
	error( "Installation failed: failed to write to config file", 0 )
end

for i = 1, 2 do
	print( ("Allow a startup patch for easier usage of the build system? (Y/n%s)"):format( i == 1 and "/info" or "" ) )

	local event, key

	repeat
		event, key = os.pullEventRaw()
	until event == "key"

	if key == keys.y or key == keys.enter then
		local h, content = fs.open( "startup", "r" ), ""

		if h then
			content = h.readAll()
			h.close()
		elseif fs.exists "startup" then
			return error( "Failed to open startup", 0 )
		end

		local h = fs.open( "startup", "w" )

		if h then
			h.writeLine( ("shell.setAlias( 'sbs', '%s/bin/sbs.lua' )"):format( path ) )
			h.write( content )
			h.close()
		end

		break
	elseif key == keys.i and i == 1 then
		print( PATCH_INFO:format( path ) )
	else
		break
	end
end

shell.setAlias( "sbs", ("%s/bin/sbs.lua"):format( path ) )
