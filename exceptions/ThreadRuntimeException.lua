
-- @once
-- @print Including sheets.exceptions.ThreadRuntimeException

class "ThreadRuntimeException" extends "Exception"

function ThreadRuntimeException:ThreadRuntimeException( data, level )
	return self:Exception( "ThreadRuntimeException", data, level )
end
