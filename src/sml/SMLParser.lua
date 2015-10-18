
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.sml.SMLParser'
 -- @endif

 -- @print Including sheets.sml.SMLParser

local type_lookup = {
	[SML_TOKEN_STRING] = "string";
	[SML_TOKEN_EQUAL] = "equals";
	[SML_TOKEN_OPEN] = "opening bracket";
	[SML_TOKEN_CLOSE] = "closing bracket";
	[SML_TOKEN_SLASH] = "slash";
	[SML_TOKEN_NUMBER] = "number";
	[SML_TOKEN_BOOL] = "boolean";
	[SML_TOKEN_IDENTIFIER] = "identifier";
	[SML_TOKEN_UNKNOWN] = "symbol";
	[SML_TOKEN_EOF] = "EOF";
}

local stringlookupt = setmetatable( { n = "\n", r = "\r", ["0"] = "\0" }, { __index = function( t, k ) return k end } )

local function matches( self, type, value )
	return self.type == type and ( value == nil or self.value == value )
end

local function Token( type, value, line, char )
	return { type = type, value = value, line = line, character = char, matches = matches }
end

local function tType( type )
	return type_lookup[type]
end

class "SMLParser" {
	text = "";
	char = 1;
	marker = 1;
	character = 1;
	line = 1;
	token = nil;
	peeking = {};
}

function SMLParser:SMLParser( str )
	self.text = str
	self.peeking = {}
end

function SMLParser:begin()
	if not self.token then
		self:next()
	end
end

function SMLParser:consume()

	local line, char = self.line, self.character
	if self.char > #self.text then
		return Token( SML_TOKEN_EOF, nil, line, char )
	end
	local c = self.text:sub( self.char, self.char )
	if c == "\"" or c == "'" then
		return self:consumeString( line, char )

	elseif self.text:find( "^<!%-%-", self.char ) then
		self:consumeComment( line, char )
		return self:consume()

	elseif c == "<" then
		self.char = self.char + 1
		self.character = self.character + 1
		return Token( SML_TOKEN_OPEN, "<", line, char )

	elseif c == ">" then
		self.char = self.char + 1
		self.character = self.character + 1
		return Token( SML_TOKEN_CLOSE, ">", line, char )

	elseif c == "/" then
		self.char = self.char + 1
		self.character = self.character + 1
		return Token( SML_TOKEN_SLASH, "/", line, char )

	elseif c == "=" or c == ":" then
		self.char = self.char + 1
		self.character = self.character + 1
		return Token( SML_TOKEN_EQUAL, c, line, char )

	elseif self.text:find( "^%.?%d", self.char ) then
		return self:consumeNumber( line, char )

	elseif c:find "[%w_]" then
		return self:consumeWord( line, char )

	elseif c == "\n" then
		self:consumeNewline( line, char )
		return self:consume()

	elseif c:find "%s" then
		self:consumeWhitespace( line, char )
		return self:consume()

	end

	self.character = self.character + 1
	self.char = self.char + 1
	return Token( SML_TOKEN_UNKNOWN, c, line, char )

end

function SMLParser:consumeWord( line, char )
	local w = self.text:match( "[a-zA-Z_][a-zA-Z_0-9]*", self.char )
	self.char = self.char + #w
	self.character = self.character + #w
	if w == "true" or w == "false" then
		return Token( SML_TOKEN_BOOL, w == "true", line, char )
	end
	return Token( SML_TOKEN_IDENTIFIER, w, line, char )
end

function SMLParser:consumeNumber( line, char )
	local n = self.text:match( "%d*%.?%d+", self.char )
	if self.text:sub( self.char + #n, self.char + #n ) == "e" then
		n = n .. ( self.text:match( "^e%-?%d+", self.char + #n ) or error( "[" .. line .. ", " .. char .. "]: expected number after exponent 'e'", 0 ) )
	end
	self.char = self.char + #n
	self.character = self.character + #n
	return Token( SML_TOKEN_NUMBER, tonumber( n ), line, char )
end

function SMLParser:consumeString( line, char )
	local close, e, s = self.text:sub( self.char, self.char ), false, ""

	for i = self.char + 1, #self.text do
		if e then
			local ch = stringlookupt[self.text:sub( i, i )]
			if self.text:sub( i, i ) == "\n" then
				self.character = 0
				self.line = self.line + 1
			end
			s, self.character, e = s .. ch, self.character + 1, false
		elseif self.text:sub( i, i ) == "\\" then
			e = true
			self.character = self.character + 1
		elseif self.text:sub( i, i ) == close then
			self.char = i + 1
			self.character = self.character + 1
			return Token( SML_TOKEN_STRING, s, line, char )
		elseif self.text:sub( i, i ) == "\n" then
			s = s .. "\n"
			self.character = 1
			self.line = self.line + 1
		else
			s = s .. self.text:sub( i, i )
			self.character = self.character + 1
		end
	end
	return error( "[" .. line .. ", " .. char .. "]: found no closing " .. close, 0 )
end

function SMLParser:consumeComment( line, char )
	local _, e = self.text:find( "%-%->", self.char )
	if e then
		self.line = self.line + select( 2, self.text:sub( self.char, e ):gsub( "\n", "" ) )
		self.character = self.character + #self.text:sub( self.char, e ):gsub( ".+\n", "" ) + 2
		self.char = e + 2
	else
		self.char = #self.text + 1
	end
end

function SMLParser:consumeNewline()
	self.line = self.line + 1
	self.character = 1
	self.char = self.char + 1
end

function SMLParser:consumeWhitespace()
	self.char = self.char + 1
	self.character = self.character + 1
end

function SMLParser:next()
	local t = self.token
	self.token = table.remove( self.peeking, 1 ) or self:consume()
	return t
end

function SMLParser:peek( n )
	if ( n or 0 ) == 0 then
		return self.token
	end
	for i = #self.peeking + 1, n do
		self.peeking[i] = self:consume()
	end
	return self.peeking[n]
end

function SMLParser:test( type, value, n )
	return self:peek( n ):matches( type, value ) and self:peek( n ) or nil
end

function SMLParser:skip( type, value )
	return self.token:matches( type, value ) and self:next() or nil
end

function SMLParser:parseAttribute()
	local ident = self:skip( SML_TOKEN_IDENTIFIER ).value
	if self:skip( SML_TOKEN_EQUAL ) then
		local value = self:next()
		if value.type == SML_TOKEN_STRING or value.type == SML_TOKEN_IDENTIFIER or value.type == SML_TOKEN_NUMBER or value.type == SML_TOKEN_BOOL then
			return ident, value.value
		else
			return error( "[" .. value.line .. ", " .. value.character .. "]: unexpected " .. tType( value.type ) )
		end
	else
		return ident, true
	end
end

function SMLParser:parseAttributes()
	local a = {}
	while self:test( SML_TOKEN_IDENTIFIER ) do
		local k, v = self:parseAttribute()
		a[k] = v
	end
	return a
end

function SMLParser:parseObject()
	if self:test( SML_TOKEN_IDENTIFIER ) then
		local name = self:skip( SML_TOKEN_IDENTIFIER ).value
		local attributes = self:parseAttributes()

		if self:skip( SML_TOKEN_SLASH ) then
			if not self:skip( SML_TOKEN_CLOSE ) then
				return error( "[" .. self:peek().line .. ", " .. self:peek().character .. "]: expected '>' after '/'", 0 )
			end
			return SMLNode( name, attributes )
		else
			if not self:skip( SML_TOKEN_CLOSE ) then
				return error( "[" .. self:peek().line .. ", " .. self:peek().character .. "]: expected '>' after '/'", 0 )
			end
			return SMLNode( name, attributes, self:parseBody( name ) )
		end
	else
		return error( "[" .. self:peek().line .. ", " .. self:peek().character .. "]: expected object type, got " .. tType( self:peek().type ), 0 )
	end
end

function SMLParser:parseBody( closing )
	local body = {}
	while self:skip( SML_TOKEN_OPEN ) do
		if self:test( SML_TOKEN_SLASH ) then
			if closing then
				self:next()
				if self:test( SML_TOKEN_IDENTIFIER ) then
					if not self:skip( SML_TOKEN_IDENTIFIER, closing ) then
						return error( "[" .. self:peek().line .. ", " .. self:peek().character .. "]: unexpected closing tag for '" .. self:peek().value .. "', expected '" .. closing .. "'", 0 )
					end
				end
				if self:skip( SML_TOKEN_CLOSE ) then
					return body
				else
					return error( "[" .. self:peek().line .. ", " .. self:peek().character .. "]: expected '>' after '/'", 0 )
				end
			else
				return error( "[" .. self:peek().line .. ", " .. self:peek().character .. "]: unexpected closing tag", 0 )
			end
		else
			body[#body + 1] = self:parseObject()
		end
	end
	return body
end
