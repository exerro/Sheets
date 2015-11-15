
local open = { ["if"] = true, ["ifn"] = true, ["ifdef"] = true, ["ifndef"] = true }
local stop = { ["elif"] = true, ["elifn"] = true, ["elifdef"] = true, ["elifndef"] = true, ["else"] = true, ["endif"] = true }

local function checker( self, mode, data )
	if mode == 0 then
		return self.env[data]
	elseif mode == 1 then
		return not self.env[data]
	elseif mode == 2 then
		return self.env[data] ~= nil
	elseif mode == 3 then
		return self.env[data] == nil
	end
end

local function getnext( self )
	local l, d, i = 0, self:fetch()
	while d do
		self:write ""
		if open[i] then
			l = l + 1
		elseif stop[i] and l == 0 then
			return i, d
		elseif i == "endif" then
			l = l - 1
		end
		d, i = self:fetch()
	end
end

local function skip_to_next( self )
	local i, d = getnext( self )
	return i == "elif" and 0 or i == "elifn" and 1 or i == "elifdef" and 2 or i == "elifndef" and 3 or i == "else" and 4 or i == "endif" and 5, d
end

local function skip_to_end( self )
	local i = getnext( self )
	while i do
		if i == "endif" then return end
		i = getnext( self )
	end
	return error( "Expected '@endif'", 0 )
end

local function execute( self )
	local d, i = self:fetch()
	while d do
		if stop[i] then
			self:write ""
			return i ~= "endif" and skip_to_end( self )
		elseif i then
			self:execute( i, d )
		else
			self:write( d )
		end
		d, i = self:fetch()
	end
	return error( "Expected '@endif'", 0 )
end

local function block( self, mode, data )
	self:write ""
	if checker( self, mode, data ) then -- successful check
		return execute( self ) -- execute and return
	else
		while true do
			local mode, data = skip_to_next( self ) -- gets next valid instruction
			if mode == 4 then -- else statement
				return execute( self ) -- execute and return
			elseif mode == 5 then -- got to an end with no successful branch
				return
			elseif not mode then -- no valid instruction
				return error( "Expected '@endif'", 0 ) -- therefore missing an endif
			else -- got an instruction, check
				if checker( self, mode, data ) then -- successful check
					return execute( self ) -- execute and return
				end
			end
		end
	end
end

local module = {}

module["if"] = function( self, data )
	return block( self, 0, data )
end

function module:ifn( data )
	return block( self, 1, data )
end

function module:ifdef( data )
	return block( self, 2, data )
end

function module:ifndef( data )
	return block( self, 3, data )
end

function module:elif( data )
	return error( "Unexpected '@elif' with no initial '@if'", 0 )
end

function module:elifdef( data )
	return error( "Unexpected '@elifn' with no initial '@if'", 0 )
end

function module:elifn( data )
	return error( "Unexpected '@elifdef' with no initial '@if'", 0 )
end

function module:elifndef( data )
	return error( "Unexpected '@elifndef' with no initial '@if'", 0 )
end

module["else"] = function( self, data )
	return error( "Unexpected '@else' with no initial '@if'", 0 )
end

function module:endif( data )
	return error( "Unexpected '@endif' with no initial '@if'", 0 )
end

return module
