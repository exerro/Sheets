
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IHasID'
 -- @endif

 -- @print Including sheets.interfaces.IHasID

IHasID = {
	id = "ID";
}

function IHasID:setID( id )
	self.id = id
	return self
end
