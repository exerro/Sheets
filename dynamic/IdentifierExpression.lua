
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.IdentifierExpression'
 -- @endif

 -- @print Including sheets.dynamic.IdentifierExpression

class "IdentifierExpression" extends "Expression" {
	name = "";
	const_value = nil;
}

function IdentifierExpression:IdentifierExpression( position, name )
	parameters.checkConstructor( self.class, 2, "position", TokenPosition, position, "name", "string", name )

	self.name = name
	self.position = position
end

function IdentifierExpression:resolve( env )
	return self.const_value or env:get( self.name )
end

function IdentifierExpression:substitute( env )
	self.const_value = env:get( self.name )
end

function IdentifierExpression:isConstant()
	return self.const_value ~= nil
end

function IdentifierExpression:tostring()
	return self.name
end
