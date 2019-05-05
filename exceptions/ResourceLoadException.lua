
 -- @print including(exceptions.ResourceLoadException)

@private
@class ResourceLoadException extends Exception {

}

function ResourceLoadException:ResourceLoadException( ... )
	return self:Exception( self:type(), ... )
end
