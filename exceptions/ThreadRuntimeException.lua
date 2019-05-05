
 -- @print including(exceptions.ThreadRuntimeException)

@private
@class ThreadRuntimeException extends Exception {
	thread = nil;
}

function ThreadRuntimeException:ThreadRuntimeException( thread, ... )
	self.thread = thread

	return self:Exception( self:type(), ... )
end

function ThreadRuntimeException:get_thread()
	return self.thread
end
