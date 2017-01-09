
 -- @once
 -- @print Including sheets.exceptions.ResourceLoadException

class "ResourceLoadException" extends "Exception"

function ResourceLoadException:ResourceLoadException( data, level )
	return self:Exception( "ResourceLoadException", data, level )
end
