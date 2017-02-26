
 -- @print including(exceptions.ThreadRuntimeException)

@private
@class ThreadRuntimeException extends Exception {

}

function ThreadRuntimeException:ThreadRuntimeException( data, level )
	return self:Exception( "ThreadRuntimeException", data, level )
end
