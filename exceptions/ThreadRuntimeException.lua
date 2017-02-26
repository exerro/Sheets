
 -- @print including(exceptions.ThreadRuntimeException)

@private
@class ThreadRuntimeException extends Exception {
	thread = nil;
}

function ThreadRuntimeException:ThreadRuntimeException( thread, data, level )
	self.thread = thread

	return self:Exception( "ThreadRuntimeException", data, level )
end

function ThreadRuntimeException:get_thread()
	return self.thread
end
