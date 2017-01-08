
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.ExpressionException'
 -- @endif

 -- @print Including sheets.exceptions.ExpressionException

class "ExpressionException" extends "Exception" {
	position = nil;
}

function ExpressionException:ExpressionException( data, position )
	parameters.checkConstructor( self.class, 1, "position", TokenPosition, position )
	self.position = position
	return self:Exception( "ExpressionException", data, 0 )
end

function ExpressionException:getData()
	if type( self.data ) == "string" or class.isClass( self.data ) or class.isInstance( self.data ) then
		return self.position:tostring() .. ": " .. tostring( self.data )
	else
		return self.position:tostring() .. ": " .. textutils.serialize( seld.data )
	end
end
