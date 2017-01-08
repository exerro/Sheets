
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.ConstantExpression'
 -- @endif

 -- @print Including sheets.dynamic.ConstantExpression

class "ConstantExpression" extends "Expression" {
	value = 0;
}

function ConstantExpression:ConstantExpression( position, value )
	parameters.checkConstructor( self.class, 1, "position", TokenPosition, position )
	self.value = value
	self.position = position
end

function ConstantExpression:resolve( env )
	return self.value
end

function ConstantExpression:isConstant()
	return true
end

function ConstantExpression:tostring()
	return tostring( self.value )
end
