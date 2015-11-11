
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.IncorrectConstructorException'
 -- @endif

 -- @print Including sheets.exceptions.IncorrectConstructorException

class "IncorrectConstructorException" extends "Exception"

function IncorrectConstructorException:IncorrectConstructorException( data, level )
	return self:Exception( "IncorrectConstructorException", data, level )
end
