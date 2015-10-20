
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IEvent'
 -- @endif

 -- @print Including sheets.interfaces.IEvent

IEvent = {
	event = nil;
	handled = false;
}

function IEvent:IEvent( event )
	self.event = event
end

function IEvent:is( event )
	return self.event == event
end

function IEvent:handle()
	self.handled = true
end
