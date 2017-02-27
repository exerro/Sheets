
 -- @include SourceCodeException

 -- @print including(exceptions.StreamException)

@private
@class StreamException extends SourceCodeException {

}

function StreamException.unfinished_string( position )
	return StreamException( "unfinished string", position )
end

function StreamException.unexpected_symbol( symbol, position )
	return StreamException( "unexpected symbol '" .. symbol .. "'", position )
end
