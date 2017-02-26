
 -- @include SourceCodeException

 -- @print including(exceptions.DynamicValueException)

@private
@class DynamicValueException extends SourceCodeException {

}

function DynamicValueException.app_no_parent( position )
	return DynamicValueException( "failed attempt to reference 'parent' index of Application", position )
end
