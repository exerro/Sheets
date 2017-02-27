
 -- @print including(exceptions.IncorrectConstructorException)

@private
@class IncorrectConstructorException extends Exception {

}

function IncorrectConstructorException:IncorrectConstructorException( ... )
	return self:Exception( self:type(), ... )
end
