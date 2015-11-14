
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.Event'
 -- @endif

 -- @print Including sheets.events.Event

class "Event" {
	event = "Event";
}

function Event:tostring()
	return self.name
end

function Event:is( event )
	return self.event == event
end

function Event:handle( handler )
	self.handled = true
	self.handler = handler
end
