
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.ResourceLoadException'
 -- @endif

 -- @print Including sheets.exceptions.ResourceLoadException

class "ResourceLoadException" extends "Exception"

function ResourceLoadException:ResourceLoadException( data, level )
	return self:Exception( "ResourceLoadException", data, level )
end
