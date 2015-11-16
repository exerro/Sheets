
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.ExpressionParser'
 -- @endif

 -- @print Including sheets.dynamic.ExpressionParser

local operators = {
	["+"] = true;
	["-"] = OPERATOR_UNARY_MINUS;
	["*"] = true;
	["/"] = true;
	["%"] = true;
	["^"] = true;
	["#"] = OPERATOR_UNARY_LEN;
	["!"] = OPERATOR_UNARY_NOT;
}

local binary_operators = {
	["+"] = OPERATOR_BINARY_ADD;
	["-"] = OPERATOR_BINARY_SUB;
	["*"] = OPERATOR_BINARY_MUL;
	["/"] = OPERATOR_BINARY_DIV;
	["%"] = OPERATOR_BINARY_MOD;
	["^"] = OPERATOR_BINARY_POW;
}

local precedence = {
	["+"] = 0;
	["-"] = 0;
	["*"] = 1;
	["/"] = 1;
	["%"] = 1;
	["^"] = 2;
}

class "ExpressionParser" extends "Parser" {
	token = 1;
}

function ExpressionParser:consume()
	if self:finished() then
		return Token( TOKEN_EOF, nil, self.position )
	end

	if self:matchString() then
		return self:consumeString()
	elseif self:matchNumber() then
		return self:consumeNumber()
	elseif self:matchIdentifier() then
		return self:consumeIdentifier()
	elseif self:matchWhitespace() then
		return self:consumeWhitespace()
	else
		self.character = self.character + 1
		if operators[self.text:sub( self.character - 1, self.character - 1 )] then
			return Token( TOKEN_OPERATOR, self.text:sub( self.character - 1, self.character - 1 ), self:advancePosition( 1 ) )
		end
		return Token( TOKEN_SYMBOL, self.text:sub( self.character - 1, self.character - 1 ), self:advancePosition( 1 ) )
	end
end

function ExpressionParser:peek( n )
	return self.tokens[self.token + ( n or 0 )] or Token( TOKEN_EOF, nil, self.position )
end

function ExpressionParser:next()
	self.token = self.token + 1
	return self:peek( -1 )
end

function ExpressionParser:test( ... )
	return self:peek():matches( ... )
end

function ExpressionParser:parseUnaryLeftOperator()
	if self:test( TOKEN_OPERATOR, "-" ) or self:test( TOKEN_OPERATOR, "#" ) or self:test( TOKEN_OPERATOR, "!" ) then
		return self:next()
	end
end

function ExpressionParser:parseUnaryRightOperator( lvalue )
	if self:test( TOKEN_SYMBOL, "(" ) then
		-- stuff
	elseif self:test( TOKEN_SYMBOL, "." ) then
		-- stuff
	end
	return lvalue
end

function ExpressionParser:parseAtom()
	if self:test( TOKEN_STRING ) or self:test( TOKEN_INT ) or self:test( TOKEN_FLOAT ) then
		return ConstantExpression( self:peek().position, self:next().value )
	elseif self:test( TOKEN_IDENT ) then
		return IdentifierExpression( self:peek().position, self:next().value )
	else
		Exception.throw( ParserException( "expected constant or identifier, got " .. self:peek().token, self:peek().position ) )
	end
end

function ExpressionParser:parseNode()
	local lops = {}
	local node
	while true do
		local lop = self:parseUnaryLeftOperator()
		if lop then
			lops[#lops + 1] = lop
		else
			break
		end
	end

	node = self:parseAtom()

	while true do
		local rop = self:parseUnaryRightOperator( node )
		if rop ~= node then
			node = rop
		else
			break
		end
	end

	for i = #lops, 1, -1 do
		node = UnaryLeftExpression( lops[i].position, operators[lops[i].value], node )
	end

	return node
end

function ExpressionParser:parseBinaryOperator( lvalue )
	local operator = self:peek().value
	local position = self:next().position
	local p = precedence[operator]
	local rvalue = self:parseNode()

	while true do
		if self:test( TOKEN_OPERATOR ) then
			local op = self:peek().value
			position = self:peek().position

			if not precedence[op] then
				Exception.throw( ParserException( "expected binary operator, got " .. self:peek().token, self:peek().position ) )
			end

			if precedence[op] > p then
				rvalue = self:parseBinaryOperator( rvalue )
			elseif precedence[op] == p then
				return self:parseBinaryOperator( BinaryExpression( position, lvalue, binary_operators[operator], rvalue ) )
			else
				return BinaryExpression( position, lvalue, binary_operators[operator], rvalue )
			end
		else
			return BinaryExpression( position, lvalue, binary_operators[operator], rvalue )
		end
	end
end

function ExpressionParser:parseExpression()
	local lvalue = self:parseNode()

	while self:test( TOKEN_OPERATOR ) do
		if precedence[self:peek().value] then
			lvalue = self:parseBinaryOperator( lvalue )
		else
			Exception.throw( ParserException( "expected binary operator, got " .. self:peek().token, self:peek().position ) )
		end
	end
	if not self:test( TOKEN_EOF ) then
		Exception.throw( ParserException( "unexpected " .. self:peek().token, self:peek().position ) )
	end

	return lvalue
end
