
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.parsing.Parser'
 -- @endif

 -- @print Including sheets.parsing.Parser

local escapes = { ["n"] = "\n", ["r"] = "\r", ["0"] = "\0" }

class "Parser" {
	position = TokenPosition();
	character = 1;
	text = "";
	tokens = {};
}

function Parser:Parser( str, source )
	source = source or "string"
	str = str or ""

	parameters.checkConstructor( self.class, 2, "string", "string", str, "source", "string", source )

	self.text = str
	self.position = TokenPosition( source, 1, 1 )
end

function Parser:throw( err )
	Exception.throw( ParserException( self.position:tostring() .. ": " .. tostring( err ), 0 ) )
end

function Parser:advancePosition( n )
	local p = self.position:clone()
	self.position:addOn( n or 1 )
	return p
end

function Parser:finished()
	return self.character > #self.text
end

function Parser:push( token )
	parameters.check( 1, "token", Token, token )
	self.tokens[#self.tokens + 1] = token
end

function Parser:consume()
	if self:finished() then
		return Token( TOKEN_EOF, nil, self.position )
	end

	return Token( TOKEN_SYMBOL, self.text:sub( self.character, self.character ), self:advancePosition( 1 ) )
end

function Parser:lex()
	while true do
		local token = self:consume()
		if token:matches( TOKEN_EOF ) then
			break
		else
			self:push( token )
		end
	end
end

function Parser:consumeString()
	local close = self.text:sub( self.character, self.character )
	local escaped = false
	local text = self.text
	local str = ""

	local pos = self.position:add( 1 )
	local start = self.position:clone()

	for i = self.character + 1, #text do
		local char = text:sub( i, i )

		if char == "\n" then
			pos.character = 0
			pos.line = pos.line + 1
		end

		if escaped then
			str = str .. ( escapes[char] or char )
			escaped = false
		elseif char == close then
			self.character = i + 1
			self.position = pos + 1
			return Token( TOKEN_STRING, str, start )
		else
			str = str .. char
		end

		pos:addOn( 1 )
	end

	return self:throw( "expected " .. close .. " to end string" )
end

function Parser:consumeNumber()
	local text = self.text
	local n = text:match( "^%d*%.?%d+", self.character )
	local e = text:match( "^e(%-?%d+)", self.character + #n )
	local added = #n + ( e and #e + 1 or 0 )
	local f = text:sub( self.character + added, self.character + added ) == "f"
	local isInt = not n:find "%." and ( not e or e:sub( 1, 1 ) ) ~= "-" and not f
	local num = tonumber( n ) * 10 ^ tonumber( e or 0 )

	if f then
		added = added + 1
	end

	self.character = self.character + added

	if isInt then
		return Token( TOKEN_INT, num, self:advancePosition( added ) )
	else
		return Token( TOKEN_FLOAT, num, self:advancePosition( added ) )
	end
end

function Parser:consumeIdentifier()
	local ident = self.text:match( "^[%w_]+", self.character )
	self.character = self.character + #ident
	return Token( TOKEN_IDENT, ident, self:advancePosition( #ident ) )
end

function Parser:consumeSymbol()
	self.character = self.character + 1
	return Token( TOKEN_SYMBOL, self.text:sub( self.character - 1, self.character - 1 ), self:advancePosition( 1 ) )
end

function Parser:consumeNewline()
	self.position.character = 1
	self.position.line = self.position.line + 1
	return self:consume()
end

function Parser:consumeWhitespace()
	local l = #( self.text:match( "^[^\n%S]+", self.character + 1 ) or "" )

	if self.text:sub( self.character, self.character ) == "\n" then
		self.position.line = self.position.line + 1
		self.position.character = l + 1
	else
		self.position:addOn( l + 1 )
	end
	
	self.character = self.character + 1 + l

	return self:consume()
end

function Parser:consumeXMLComment()
	local comment = self.text:match( "^<!%-%-.-%-%->", self.character )

	if comment then
		local lines = select( 2, comment:gsub( "\n", "" ) )
		local length = #comment:gsub( "^.+\n", "" )

		self.character = self.character + #comment

		if lines > 0 then
			self.position.character = 1
			self.position:addOn( TokenPosition( "", lines, length ) )
		else
			self.position:addOn( length )
		end
	else
		self:throw "expected end to comment ('-->')"
	end

	return self:consume()
end

function Parser:matchString()
	local char = self.text:sub( self.character, self.character )
	return char == "'" or char == '"'
end

function Parser:matchNumber()
	return self.text:find( "^%d*%.?%d", self.character ) ~= nil
end

function Parser:matchIdentifier()
	return self.text:find( "^[%w_]", self.character ) ~= nil
end

function Parser:matchSymbol()
	return true
end

function Parser:matchNewline()
	return self.text:sub( self.character, self.character ) == "\n"
end

function Parser:matchWhitespace()
	return self.text:find( "^%s", self.character ) ~= nil
end

function Parser:matchXMLComment()
	return self.text:sub( self.character, self.character + 3 ) == "<!--"
end
