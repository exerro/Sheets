
 -- @include SourceCodeException

 -- @print including(exceptions.StreamException)

@private
@class StreamException extends SourceCodeException {

}

function StreamException.unfinished_string( ... )
	return StreamException( "unfinished string", ... )
end

function StreamException.unexpected_symbol( symbol, ... )
	return StreamException( "unexpected symbol '" .. symbol .. "'", ... )
end
