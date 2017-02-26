
 -- @print including(exceptions.IncorrectParameterException)

@private
@class IncorrectParameterException extends Exception {

}

function IncorrectParameterException:IncorrectParameterException( data, level )
	return self:Exception( "IncorrectParameterException", data, level )
end
