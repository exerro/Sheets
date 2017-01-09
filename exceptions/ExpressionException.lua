
 -- @once
 -- @print Including sheets.exceptions.ExpressionException

class "ExpressionException" extends "Exception" {
	position = nil;
}

function ExpressionException:ExpressionException( data, position )
	parameters.check_constructor( self.class, 1, "position", TokenPosition, position )
	self.position = position
	return self:Exception( "ExpressionException", data, 0 )
end

function ExpressionException:get_data()
	if type( self.data ) == "string" or class.is_class( self.data ) or class.is_instance( self.data ) then
		return self.position:tostring() .. ": " .. tostring( self.data )
	else
		return self.position:tostring() .. ": " .. textutils.serialize( seld.data )
	end
end
