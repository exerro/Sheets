
local args = { ... }

local env = setmetatable( {}, { __index = _ENV } )
local preprocessor

local paths = {}
local main = "main"
local penv = {}
local outputs = {}

local mode = "path"

local h = fs.open( "sheets/build/preprocessor.lua", "r" )
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

local prev
for i = 1, #args do
	prev = mode ~= "main" and mode or prev
	if args[i] == "-m" then
		mode = "main"
	elseif args[i] == "-d" then
		mode = "path"
	elseif args[i] == "-o" then
		mode = "output"
	elseif args[i] == "-f" then
		mode = "flag"
	elseif mode == "main" then
		main = args[i]:gsub( "%.", "/" )
		mode = prev
	elseif mode == "path" then
		paths[#paths + 1] = args[i]:gsub( "%.", "/" )
	elseif mode == "output" then
		outputs[#outputs + 1] = args[i]
	elseif mode == "flag" then
		penv[args[i]] = true
	end
end

outputs[1] = outputs[1] or "?/output"

if #paths == 0 then
	return error( "Expected one or more build paths", 0 )
end

local p = preprocessor()
p.include_paths = paths
p.env = penv
p.active_include = main .. ".lua"

paths[#paths + 1] = ""
paths[#paths + 1] = "sheets"

for i = 1, #paths do
	local h = fs.open( paths[i] .. "/" .. main .. ".lua", "r" )
	if h then
		local content = h.readAll()
		h.close()

		p:push( content )

		local r = p:build()

		for i = 1, #outputs do
			local file = outputs[i]:gsub( "%?", paths[1] ):gsub( "%.", "/" ) .. ".lua"
			local h = fs.open( file, "w" )
			if h then
				h.write( r )
				h.close()
			else
				return error( "Failed to write to output file '" .. outputs[i] .. "'", 0 )
			end
		end

		return
	end
end

return error( "Failed to find main file (" .. main .. ".lua) in paths given", 0 )
