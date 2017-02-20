
 -- @print including(events.Event)

@class Event {
	event = "Event";
}

function Event:is( event )
	return self.event == event
end

function Event:handle( handler )
	self.handled = true
	self.handler = handler
end
