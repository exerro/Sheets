
 -- @print including(events.MiscEvent)

@class MiscEvent extends Event {
	event = "MiscEvent";
	parameters = {};
}

function MiscEvent:MiscEvent( event, ... )
	self.event = event
	self.parameters = { ... }
end
