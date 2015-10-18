
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.KeyboardEvent'
 -- @endif

 -- @print Including sheets.events.KeyboardEvent

class "KeyboardEvent" implements (IEvent) {
	
}

function KeyboardEvent:KeyboardEvent()
	self:IEvent()
end
