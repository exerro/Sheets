
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.MiscEvent'
 -- @endif

 -- @print Including sheets.events.MiscEvent

class "MiscEvent" {
	event = "MiscEvent";
	parameters = {};
}

function MiscEvent:MiscEvent( event, ... )
	self.event = event
	self.parameters = { ... }
end

function MiscEvent:is( event )
	return self.event == event
end

function MiscEvent:handle( handler )
	self.handled = true
	self.handler = handler
end
