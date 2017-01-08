
local preprocessor = {}
local path = "sheets/res/instructions"

local function loadModule( self, path, name )
	if self.module_loaded[path] then return end
	self.module_loaded[path] = true

	local h = fs.open( path, "r")
	if h then
		local content = h.readAll()
		h.close()

		local f, err = load( content, name, nil, _ENV )
		if f then
			f, err = pcall( f, self )
		end
		if not f then
			return error( err, 0 )
		end
		if type( err ) == "table" then
			for k, v in pairs( err ) do
				if type( v ) ~= "function" then
					return error( "Module tried to add non-function instruction", 0 )
				elseif self.instruction_list[k] then
					print( "Duplicated instruction name '" .. k .. "'" )
				end
				self.instruction_list[k] = v
			end
		end
	end
end

local function load( self, data )
	self:write ""
	if fs.exists( data:gsub( "%.", "/" ) .. ".lua" ) then
		loadModule( self, data:gsub( "%.", "/" ) .. ".lua", data )
	else
		return error( "No such module '" .. data .. "'", 0 )
	end
end

function preprocessor:fetch()
	local s = self.stack[#self.stack]
	if not s then return end
	s.line = s.line + 1
	if s.instructions[s.iptr] and s.instructions[s.iptr].line == s.line then
		s.iptr = s.iptr + 1
		return s.instructions[s.iptr - 1].data, s.instructions[s.iptr - 1].instruction
	end
	return s.lines[s.line], nil
end

function preprocessor:write( data )
	local s = self.stack[#self.stack]
	if not s then return end
	local c, _c = 1
	while c ~= 0 do
		c = 0
		for k, v in pairs( self.macros ) do
			data, _c = ( " " .. data .. " " ):gsub( "([^%w_])" .. k .. "([^%w_])", "%1" .. v .. "%2" )
			data = data:sub( 2, -2 )
			c = c + _c
		end
	end
	s.output[#s.output + 1] = data
end

function preprocessor:execute( i, d )
	if self.instruction_list[i] then
		self.instruction_list[i]( self, d )
	else
		return error( "Unknown instruction '" .. i .. "'", 0 )
	end
end

function preprocessor:push( str )
	local lines, instructions, line = {}, {}

	while str do
		line = str:match "^(.-)\n" or str
		str = str:match "^.-\n(.+)"
		if line and line:find "^%s*%-?%-?%s*@%s*[%w_]" then
			instructions[#instructions + 1] = { line = #lines + 1, instruction = line:match "^%s*%-?%-?%s*@%s*([%w_]+)":lower(), data = line:gsub( "^%s*%-?%-?%s*@%s*[%w_]+%s*", "" ) }
			line = ""
		end

		lines[#lines + 1] = line
	end

	self.stack[#self.stack + 1] = {
		lines = lines;
		instructions = instructions;
		line = 0;
		iptr = 1;
		output = {};
	}
end

function preprocessor:build()
	local d, i = self:fetch()
	while d do
		if i then
			self:execute( i, d )
		else
			self:write( d )
		end
		d, i = self:fetch()
	end
	return table.concat( table.remove( self.stack, #self.stack ).output, "\n" )
end

return function()

	local s = {}

	s.env = {}
	s.include_paths = { "" }
	s.instruction_list = { load = load }

	s.module_loaded = {}
	s.macros = {}

	s.stack = {}

	loadModule( s, path .. "/conditional.lua", "conditional" )
	loadModule( s, path .. "/console.lua", "error" )
	loadModule( s, path .. "/define.lua", "define" )
	loadModule( s, path .. "/include.lua", "include" )

	return setmetatable( s, { __index = preprocessor } )

end
