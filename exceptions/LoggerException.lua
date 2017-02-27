
 -- @include Exception

 -- @print including(exceptions.LoggerException)

@private
@class LoggerException extends Exception {

}

function LoggerException:LoggerException( ... )
	return self:Exception( self:type(), ... )
end

function LoggerException.file_open_failed( path, level )
	return LoggerException( "failed to open log file '" .. path .. "' in write mode", level or 1 )
end
