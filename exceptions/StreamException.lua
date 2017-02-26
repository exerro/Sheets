
 -- @include SourceCodeException

 -- @print including(exceptions.StreamException)

@private
@class StreamException extends SourceCodeException {

}

function StreamException.unfinished_string( src, char, strl, line )
	return StreamException( "unfinished string", { source = src, character = char, strline = strl, line = line } )
end

function StreamException.unexpected_symbol( symbol, src, char, strl, line )
	return StreamException( "unexpected symbol '" .. symbol .. "'", { source = src, character = char, strline = strl, line = line } )
end
