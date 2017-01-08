
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.Expression'
 -- @endif

 -- @print Including sheets.dynamic.Expression

class "Expression" {
	position = nil;
}

function Expression:Expression( position )
	self.position = position
end

function Expression:resolve( env )

end

function Expression:substitute( env )

end

function Expression:isConstant()
	
end

function Expression:tostring()

end

function Expression:throw( err )
	return Exception.throw( ExpressionException( self.position:tostring() .. ": " .. tostring( err ), 0 ) )
end
