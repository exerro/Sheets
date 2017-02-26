
 -- @print including(exceptions.ResourceLoadException)

@private
@class ResourceLoadException extends Exception {

}

function ResourceLoadException:ResourceLoadException( data, level )
	return self:Exception( "ResourceLoadException", data, level )
end
