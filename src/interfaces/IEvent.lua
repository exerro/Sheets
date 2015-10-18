
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IEvent'
 -- @endif

 -- @print Including sheets.interfaces.IEvent

IEvent = {}

function IEvent:IEvent( type )
	self.event_type = type
end

function IEvent:is( type )
	return self.event_type == type
end
