
 -- @once
 -- @print Including sheets.parsing.Token

class "Token" {
	token = "";
	value = "";
	position = TokenPosition();
}

function Token:Token( token, value, position )
	token = token or TOKEN_EOF
	value = value or ""
	position = position or TokenPosition()

	parameters.check_constructor( self.class, 3, "token", "string", token, "value", type( value ), value, "position", TokenPosition, position )

	self.token = token
	self.value = value
	self.position = position
end

function Token:tostring()
	return self.token .. " (" .. tostring( self.value ) .. ") {" .. self.position:tostring() .. "}"
end

function Token:compare( other, value )
	if type( other ) == "string" then
		return other == self.token and ( value == nil or value == self.value and 2 or 1 ) or 0
	else
		parameters.check( 1, "token", Token, other )
		return self.token == other.token and ( self.value == other.value and 2 or 1 ) or 0
	end
end

function Token:matches( other, value )
	if type( other ) == "string" then
		return other == self.token and value == nil or value == self.value
	else
		parameters.check( 1, "token", Token, other )
		return self.token == other.token and self.value == other.value
	end
end
