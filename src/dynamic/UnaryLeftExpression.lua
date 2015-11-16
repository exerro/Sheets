
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.UnaryLeftExpression'
 -- @endif

 -- @print Including sheets.dynamic.UnaryLeftExpression

class "UnaryLeftExpression" extends "Expression" {
	operator = nil;
	rvalue = nil;
}

function UnaryLeftExpression:UnaryLeftExpression( position, operator, rvalue )
	parameters.checkConstructor( self.class, 3, "position", TokenPosition, position, "operator", "number", operator, "rvalue", Expression, rvalue )

	self.operator = operator
	self.rvalue = rvalue
	self.position = position
end

function UnaryLeftExpression:resolve( env )
	local rvalue = self.rvalue:resolve( env )

	if self.operator == OPERATOR_UNARY_MINUS then
		if type( rvalue ) == "number" then
			return -rvalue
		else
			Expression.throw()
		end
	elseif self.operator == OPERATOR_UNARY_LEN then
		if type( rvalue ) == "string" then
			return #rvalue
		else
			Exception.throw( ParserException( "expected string rvalue, got " .. type( rvalue ), self.position ) )
		end
	elseif operator == OPERATOR_UNARY_NOT then
		return not rvalue
	end
end

function UnaryLeftExpression:substitute( env )
	self.rvalue:substitute( env )
end

function UnaryLeftExpression:isConstant()
	return self.rvalue:isConstant()
end

function UnaryLeftExpression:tostring()
	if self.operator == OPERATOR_UNARY_MINUS then
		return "-(" .. self.rvalue:tostring() .. ")"
	elseif self.operator == OPERATOR_UNARY_NOT then
		return "!(" .. self.rvalue:tostring() .. ")"
	elseif self.operator == OPERATOR_UNARY_LEN then
		return "#(" .. self.rvalue:tostring() .. ")"
	end
end
