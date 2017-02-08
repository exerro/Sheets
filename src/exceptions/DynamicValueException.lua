
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.DynamicValueException'
 -- @endif

 -- @print Including sheets.exceptions.DynamicValueException

class "DynamicValueException" extends "Exception"

function DynamicValueException:DynamicValueException( data, level )
	return self:Exception( "DynamicValueException", data, level )
end
