
 -- @once
 -- @print Including sheets.exceptions.ParserException

class "ParserException" extends "Exception" {
	position = nil;
}

function ParserException:ParserException( data, position )
	parameters.check_constructor( self.class, 1, "position", TokenPosition, position )
	self.position = position
	return self:Exception( "ParserException", data, 0 )
end

function ParserException:get_data()
	if type( self.data ) == "string" or class.is_class( self.data ) or class.is_instance( self.data ) then
		return self.position:tostring() .. ": " .. tostring( self.data )
	else
		return self.position:tostring() .. ": " .. textutils.serialize( seld.data )
	end
end
