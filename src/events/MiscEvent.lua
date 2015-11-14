
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.MiscEvent'
 -- @endif

 -- @print Including sheets.events.MiscEvent

class "MiscEvent" extends "Event" {
	event = "MiscEvent";
	parameters = {};
}

function MiscEvent:MiscEvent( event, ... )
	self.event = event
	self.parameters = { ... }
end
