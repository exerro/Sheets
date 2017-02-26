
 -- @include SourceCodeException

 -- @print including(exceptions.DynamicParserException)

@private
@class DynamicParserException extends SourceCodeException {

}

function DynamicParserException.disabled_queries( position )
	return DynamicParserException( "queries are disabled here", position )
end

function DynamicParserException.expected_expression( placement, position )
	return DynamicParserException( "expected expression " .. placement, position )
end

function DynamicParserException.expected_closing( symbol, position )
	return DynamicParserException( "expected closing '" .. symbol .. "'", position )
end

function DynamicParserException.invalid_dotindex( token )
	return DynamicParserException( "invalid index after '.' (expected identifier, 'parent' or 'application', got '" .. token.value .. "')", token.position )
end

function DynamicParserException.invalid_tagname( token )
	return DynamicParserException( "invalid tag name after '#' (expected identifier or keyword, got '" .. token.value .. "')", token.position )
end

function DynamicParserException.disabled_percentages( position )
	return DynamicParserException( "percentages are disabled here", position )
end

function DynamicParserException.invalid_classname( position )
	return DynamicParserException( "invalid class name after '?' (expected identifier, got '" .. token.value .. "')", token.position )
end

function DynamicParserException.invalid_property( token )
	return DynamicParserException( "invalid property name in property selectors (expected identifier, got '" .. token.value .. "')", token.position )
end

function DynamicParserException.invalid_comparison( position )
	return DynamicParserException( "invalid comparison for property selector", position )
end

function DynamicParserException.expected_query_term( position )
	return DynamicParserException( "expected query term", position )
end
