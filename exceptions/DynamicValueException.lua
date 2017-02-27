
 -- @include SourceCodeException

 -- @print including(exceptions.DynamicValueException)

@private
@class DynamicValueException extends SourceCodeException {

}

function DynamicValueException.app_no_parent( position )
	return DynamicValueException( "failed attempt to reference 'parent' index of Application", position )
end

function DynamicValueException.invalid_query_source( type, position )
	return DynamicValueException( "invalid query source (expected type Sheet|Screen|Application, got type " .. type:tostring() .. ")", position )
end

function DynamicValueException.unsupported_env_type( type, position )
	return DynamicValueException( "unsupported environment variable type (" .. type:tostring() .. ")", position )
end

function DynamicValueException.undefined_reference( ref, position )
	return DynamicValueException( "undefined reference to '" .. ref .. "'", position )
end

function DynamicValueException.invalid_type_len( type, position )
	return DynamicValueException( "invalid type to get length of (expected Any[]|String, got " .. type:tostring() .. ")", position )
end

function DynamicValueException.invalid_type_unmp( type, op, position )
	return DynamicValueException( "invalid type for unary operator '" .. op .. "' (" .. type:tostring() .. ")", position )
end

function DynamicValueException.invalid_type_dotindex( type, position )
	return DynamicValueException( "invalid type to index (expected Sheet|Screen|Application, got " .. type:tostring() .. ")", position )
end

function DynamicValueException.invalid_index_dotindex( idx, position )
	return DynamicValueException( "undefined index '" .. idx .. "'", position )
end

function DynamicValueException.invalid_rvalue_type( op, type, expected, position )
	return DynamicValueException( "invalid rhs type for operator '" .. op .. "' (expected " .. expected:tostring() .. ", got " .. type:tostring() .. ")", position )
end

function DynamicValueException.invalid_lvalue_type( op, type, expected, position )
	return DynamicValueException( "invalid lhs type for operator '" .. op .. "' (expected " .. expected:tostring() .. ", got " .. type:tostring() .. ")", position )
end

function DynamicValueException.invalid_tag_object( type, position )
	return DynamicValueException( "invalid object to test tag (expected type Sheet|Screen, got " .. type:tostring() .. ")", position )
end

function DynamicValueException.invalid_colour_value( value, position )
	return DynamicValueException( "invalid colour value '" .. value .. "'", position )
end

function DynamicValueException.invalid_alignment_value( value, position )
	return DynamicValueException( "invalid alignment value '" .. value .. "'", position )
end

function DynamicValueException.expected_eof( position )
	return DynamicValueException( "expected eof", position )
end
