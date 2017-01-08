
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.TextEvent'
 -- @endif

 -- @print Including sheets.events.TextEvent

class "TextEvent" extends "Event" {
	event = "TextEvent";
	text = "";
}

function TextEvent:TextEvent( event, text )
	self.event = event
	self.text = text
end
