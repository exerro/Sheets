
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.BinaryExpression'
 -- @endif

 -- @print Including sheets.dynamic.BinaryExpression

local tostring = {
	[OPERATOR_BINARY_ADD] = "+";
	[OPERATOR_BINARY_SUB] = "-";
	[OPERATOR_BINARY_MUL] = "*";
	[OPERATOR_BINARY_DIV] = "/";
	[OPERATOR_BINARY_MOD] = "%";
	[OPERATOR_BINARY_POW] = "^";
}

class "BinaryExpression" extends "Expression" {
	lvalue = nil;
	operator = nil;
	rvalue = nil;
}

function BinaryExpression:BinaryExpression( position, lvalue, operator, rvalue )
	parameters.checkConstructor( self.class, 4, "position", TokenPosition, position, "lvalue", Expression, lvalue, "operator", "number", operator, "rvalue", Expression, rvalue )

	self.position = position
	self.lvalue = lvalue
	self.operator = operator
	self.rvalue = rvalue
end

function BinaryExpression:resolve( env )
	local lvalue, rvalue = self.lvalue:resolve( env ), self.rvalue:resolve( env )

	if type( lvalue ) ~= "number" then
		Exception.throw( ParserException( "expected number lvalue, got " .. type( lvalue ), self.position ) )
	elseif type( rvalue ) ~= "number" then
		Exception.throw( ParserException( "expected string rvalue, got " .. type( rvalue ), self.position ) )
	end

	if self.operator == OPERATOR_BINARY_ADD then
		return lvalue + rvalue
	elseif self.operator == OPERATOR_BINARY_SUB then
		return lvalue - rvalue
	elseif self.operator == OPERATOR_BINARY_MUL then
		return lvalue * rvalue
	elseif self.operator == OPERATOR_BINARY_DIV then
		return lvalue / rvalue
	elseif self.operator == OPERATOR_BINARY_MOD then
		return lvalue % rvalue
	elseif self.operator == OPERATOR_BINARY_POW then
		return lvalue ^ rvalue
	end
end

function BinaryExpression:substitute( env )
	self.lvalue:substitute( env )
	self.rvalue:substitute( env )
end

function BinaryExpression:isConstant()
	return self.lvalue:isConstant() and self.rvalue:isConstant()
end

function BinaryExpression:tostring()
	return "(" .. self.lvalue:tostring() .. ")" .. tostring[self.operator] .. "(" .. self.rvalue:tostring() .. ")"
end
