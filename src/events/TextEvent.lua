
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.TextEvent'
 -- @endif

 -- @print Including sheets.events.TextEvent

class "TextEvent" {
	event = "TextEvent";
	text = "";
}

function TextEvent:TextEvent( event, text )
	self.event = event
	self.text = text
end

function TextEvent:is( event )
	return self.event == event
end

function TextEvent:handle( handler )
	self.handled = true
	self.handler = handler
end
