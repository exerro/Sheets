
 -- @once
 -- @print Including sheets.exceptions.IncorrectParameterException

class "IncorrectParameterException" extends "Exception"

function IncorrectParameterException:IncorrectParameterException( data, level )
	return self:Exception( "IncorrectParameterException", data, level )
end
