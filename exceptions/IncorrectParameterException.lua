
 -- @print including(exceptions.IncorrectParameterException)

@private
@class IncorrectParameterException extends Exception {

}

function IncorrectParameterException:IncorrectParameterException( ... )
	return self:Exception( self:type(), ... )
end
