
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.IncorrectParameterException'
 -- @endif

 -- @print Including sheets.exceptions.IncorrectParameterException

class "IncorrectParameterException" extends "Exception"

function IncorrectParameterException:IncorrectParameterException( data, level )
	return self:Exception( "IncorrectParameterException", data, level )
end
