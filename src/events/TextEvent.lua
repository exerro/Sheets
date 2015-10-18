
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.TextEvent'
 -- @endif

 -- @print Including sheets.events.TextEvent

class "TextEvent" implements (IEvent) {
	
}

function TextEvent:TextEvent()
	self:IEvent()
end
