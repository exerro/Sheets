
local escape_chars = {
	["n"] = "\n";
	["r"] = "\r";
	["t"] = "\t";
}

local symbols = {
	["("] = true; [")"] = true;
	["["] = true; ["]"] = true;
	["{"] = true; ["}"] = true;
	["."] = true; [":"] = true;
	[","] = true; [";"] = true;
	["="] = true;
	["$"] = true;
	["+"] = true; ["-"] = true;
	["*"] = true; ["/"] = true;
	["%"] = true; ["^"] = true;
	["#"] = true;
	["!"] = true;
	["&"] = true; ["|"] = true;
	["?"] = true;
	[">"] = true; ["<"] = true;
	[">="] = true; ["<="] = true;
	["!="] = true; ["=="] = true;
}

local keywords = {
	["self"] = true;
	["application"] = true;
	["parent"] = true;
}

class "Stream" {
	position = 1;
	line = 1;
	character = 1;
	text = "";
}

function Stream:Stream( text )
	self.text = text
end

function Stream:consume_string()
	local text = self.text
	local close = text:sub( self.position, self.position )
	local escaped = false
	local sub = string.sub
	local str = {}

	for i = self.position + 1, #text do
		local char = sub( text, i, i )

		if char == "\n" then
			self.line = self.line + 1
			self.character = 0
		end

		if escaped then
			str[#str + 1] = escape_chars[char] or "\\" .. char
		elseif char == "\\" then
			escaped = true
		elseif char == close then
			self.position = i + 1
			return { type = TOKEN_STRING, value = table.concat( str ), position = {
				character = char, line = line;
			} }
		else
			str[#str + 1] = char
		end

		self.character = self.character + 1
	end

	error( "TODO: fix this error" )
end

function Stream:consume_identifier()
	local word = self.text:match( "[%w_]+", self.position )
	local char = self.character
	local type = keywords[word] and TOKEN_KEYWORD
		or (word == "true" or word == "false" and TOKEN_BOOLEAN)
		or TOKEN_IDENTIFIER

	self.position = self.position + #word
	self.character = self.character + #word

	return { type = type, value = word, position = {
		character = char, line = self.line;
	} }
end

function Stream:consume_number()
	local char = self.character
	local num = self.text:match( "%d*%.?%d+e[%+%-]?%d+", self.position )
	         or self.text:match( "%d*%.?%d+", self.position )
	local type = (num:find "%." or num:find "e%-")
		     and TOKEN_FLOAT or TOKEN_INTEGER

	self.position = self.position + #num
	self.character = self.character + #num

	return { type = type, value = num, position = {
		character = char, line = line;
	} }
end

function Stream:consume_whitespace()
	local line, char = self.line, self.character
	local type = TOKEN_WHITESPACE
	local value = "\n"

	if self.text:sub( 1, 1 ) == "\n" then
		self.line = self.line + 1
		self.position = self.position + 1
		self.character = 1
		type = TOKEN_NEWLINE
	else
		local n = #self.text:match( "^[^%S\n]+", self.position )

		value = self.text:sub( self.position, self.position + n - 1 )
		self.position = self.position + n
		self.character = self.character + n
	end

	return { type = type, value = value, position = {
		character = char, line = line;
	} }
end

function Stream:consume_symbol()
	local text = self.text
	local sub = string.sub
	local pos = self.position
	local s3 = sub( text, pos, pos + 2 )
	local s2 = sub( text, pos, pos + 1 )
	local s1 = sub( text, pos, pos + 0 )
	local value = s1
	local char = self.character

	if symbols[s3] then
		value = s3
	elseif symbols[s2] then
		value = s2
	elseif not symbols[s1] then
		print( s1, s2, s3 )
		error( "TODO: fix this error" )
	end

	self.character = self.character + #value
	self.position = self.position + #value

	return { type = TOKEN_SYMBOL, value = value, position = {
		character = char, line = self.line;
	} }
end

function Stream:consume()
	if self.position > #self.text then
		return { type = TOKEN_EOF, value = "", position = {
			character = self.character, line = self.line;
		} }
	end

	local char = self.text:sub( self.position, self.position )

	if char == "\"" or char == "'" then
		return self:consume_string()
	elseif char == " " or char == "\t" or char == "\n" then
		return self:consume_whitespace()
	elseif self.text:find( "^%.?%d", self.position ) then
		return self:consume_number()
	elseif char:find "%w" or char == "_" then
		return self:consume_identifier()
	else
		return self:consume_symbol()
	end
end

function Stream:is_EOF()
	return self:peek().type == TOKEN_EOF
end

function Stream:peek()
	if self.buffer then
		return self.buffer
	end

	local token = self:consume()
	self.buffer = token
	return token
end

function Stream:next()
	local token = self:peek()
	self.buffer = nil
	return token
end

function Stream:test( type, value )
	local token = self:peek()
	return token.type == type and (value == nil or token.value == value) and token or nil
end

function Stream:skip( type, value )
	local token = self:peek()
	return token.type == type and (value == nil or token.value == value) and self:next() or nil
end

function Stream:skip_value( type, value )
	local token = self:peek()
	return token.type == type and (value == nil or token.value == value) and self:next().value or nil
end
