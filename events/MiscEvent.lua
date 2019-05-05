
 -- @print including(events.MiscEvent)

@private
@class MiscEvent extends Event {
	event = "MiscEvent";
	parameters = {};
}

function MiscEvent:MiscEvent( event, ... )
	self.event = event
	self.parameters = { ... }
end
