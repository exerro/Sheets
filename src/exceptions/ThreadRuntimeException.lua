
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.ThreadRuntimeException'
 -- @endif

 -- @print Including sheets.exceptions.ThreadRuntimeException

class "ThreadRuntimeException" extends "Exception"

function ThreadRuntimeException:ThreadRuntimeException( data, level )
	return self:Exception( "ThreadRuntimeException", data, level )
end
