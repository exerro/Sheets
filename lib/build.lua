
local args = { ... }

local env = setmetatable( {}, { __index = _ENV or getfenv() } )
local preprocessor

local h = fs.open( sheets_global_config:read "install_path" .. "/lib/preprocessor.lua", "r" )

if h then
	local content = h.readAll()
	h.close()

	local f, err = load( content, "preprocessor", nil, env )
	if f then
		preprocessor = f()
	else
		error( err, 0 )
	end
else
	return error( "Cannot find file 'preprocessor'", 0 )
end

env.preprocessor = preprocessor

return function( paths, main, penv )
	local p = preprocessor()
	p.include_paths = paths
	p.env = penv
	p.active_include = main .. ".lua"

	paths[#paths + 1] = ""

	for i = 1, #paths do
		local h = fs.open( paths[i] .. "/" .. main .. ".lua", "r" )
		if h then
			local content = h.readAll()
			h.close()
			p:push( content )

			return p:build()
		end
	end

	return error( "Failed to find main file (" .. main .. ".lua) in paths given", 0 )
end
