
 -- @print including(events.TextEvent)

@class TextEvent extends Event {
	event = "TextEvent";
	text = "";
}

function TextEvent:TextEvent( event, text )
	self.event = event
	self.text = text
end
