
 -- @include Exception

 -- @print including(exceptions.LoggerException)

@private
@class LoggerException extends Exception {

}

function LoggerException:LoggerException( ... )
	return self:Exception( self:type(), ... )
end

function LoggerException.file_open_failed( path )
	return LoggerException( "failed to open log file '" .. path .. "' in write mode" )
end
