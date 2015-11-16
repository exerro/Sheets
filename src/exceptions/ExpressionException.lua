
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.ExpressionException'
 -- @endif

 -- @print Including sheets.exceptions.ExpressionException

class "ExpressionException" extends "Exception"

function ExpressionException:ExpressionException( data, level )
	return self:Exception( "ExpressionException", data, level )
end
