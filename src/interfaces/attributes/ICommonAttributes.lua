
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ICommonAttributes'
 -- @endif

 -- @print Including sheets.interfaces.ICommonAttributes

ICommonAttributes = {}

function ICommonAttributes:attribute_id( id )
	self:setID( id )
end
