
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.ParserException'
 -- @endif

 -- @print Including sheets.exceptions.ParserException

class "ParserException" extends "Exception" {
	position = nil;
}

function ParserException:ParserException( data, position )
	parameters.checkConstructor( self.class, 1, "position", TokenPosition, position )
	self.position = position
	return self:Exception( "ParserException", data, 0 )
end

function ParserException:getData()
	if type( self.data ) == "string" or class.isClass( self.data ) or class.isInstance( self.data ) then
		return self.position:tostring() .. ": " .. tostring( self.data )
	else
		return self.position:tostring() .. ": " .. textutils.serialize( seld.data )
	end
end
