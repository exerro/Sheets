
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.UnaryRightExpression'
 -- @endif

 -- @print Including sheets.dynamic.UnaryRightExpression

class "UnaryRightExpression" extends "Expression" {
	operator = nil;
	lvalue = nil;
	data = nil;
}

function UnaryRightExpression:UnaryRightExpression( position, operator, lvalue, data )
	parameters.checkConstructor( self.class, 4, "position", TokenPosition, position, "operator", "number", operator, "lvalue", Expression, lvalue, "data", operator == OPERATOR_UNARY_CALL and "table" or "string", data )

	self.operator = operator
	self.lvalue = lvalue
	self.data = data
	self.position = position
end

function UnaryRightExpression:resolve( env )
	local lvalue = self.lvalue:resolve( env )

	if self.operator == OPERATOR_UNARY_CALL then
		if type( lvalue ) == "function" then

			local args = {}
			for i = 1, #self.data do
				args[i] = self.data[i]:resolve( env )
			end

			return lvalue( unpack( args ) )

		else
			return self:throw "can't call that"
		end
	elseif self.operator == OPERATOR_UNARY_INDEX then
		if type( lvalue ) == "table" then
			return lvalue[self.data]
		else
			return self:throw "can't index that"
		end
	end
end

function UnaryRightExpression:substitute( env )

	self.lvalue:substitute( env )

	if self.operator == OPERATOR_UNARY_CALL then
		for i = 1, #self.data do
			self.data[i]:substitute( env )

			if self.data[i]:isConstant() then
				self.data[i] = self.data[i]:resolve( env )
			end
		end
	end
end

function UnaryRightExpression:isConstant()

	if self.lvalue:isConstant() then
		if self.operator == OPERATOR_UNARY_CALL then
			for i = 1, #self.data do
				if not self.data[i]:isConstant() then
					return false

				end
			end
		end
		return true
	end
	return false

end

function UnaryRightExpression:tostring()
	if self.operator == OPERATOR_UNARY_CALL then
		return stuff
	elseif self.operator == OPERATOR_UNARY_INDEX then
		return "(" .. self.lvalue:tostring() .. ")" .. "." .. self.data
	end
end
