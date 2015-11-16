
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.parsing.TokenPosition'
 -- @endif

 -- @print Including sheets.parsing.TokenPosition

class "TokenPosition" {
	line = 1;
	character = 1;
	source = "string";
}

function TokenPosition:TokenPosition( source, line, character )
	source = source or "string"
	line = line or 1
	character = character or 1

	parameters.checkConstructor( self.class, 3, "source", "string", source, "line", "number", line, "character", "number", character )

	self.source = source
	self.line = line
	self.character = character
end

function TokenPosition:tostring()
	return self.source .. " [" .. self.line .. ", " .. self.character .. "]"
end

function TokenPosition:clone()
	return TokenPosition( self.source, self.line, self.character )
end

function TokenPosition:add( position )
	if type( position ) == "number" then
		return TokenPosition( self.source, self.line, self.character + position )
	else
		parameters.check( 1, "position", TokenPosition, position )
		return TokenPosition( self.source, self.line + position.line, self.character + position.character )
	end
end

function TokenPosition:addOn( position )
	if type( position ) == "number" then
		self.character = self.character + position
	else
		parameters.check( 1, "position", TokenPosition, position )
		self.character = self.character + position.character
		self.line = self.line + position.line
	end
	return self
end

TokenPosition.meta.__add = TokenPosition.add
TokenPosition.meta.__concat = TokenPosition.addOn
