
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.ExpressionEnvironment'
 -- @endif

 -- @print Including sheets.dynamic.ExpressionEnvironment

class "ExpressionEnvironment" {
	environment = {};
}

function ExpressionEnvironment:ExpressionEnvironment()
	self.environment = {}
end

function ExpressionEnvironment:set( index, value )
	self.environment[index] = value
	return self
end

function ExpressionEnvironment:get( index )
	return self.environment[index]
end
