
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.KeyboardEvent'
 -- @endif

 -- @print Including sheets.events.KeyboardEvent

class "KeyboardEvent" implements (IEvent) {
	key = 0;
	meta = {};
}

function KeyboardEvent:KeyboardEvent( event, key, meta )
	self:IEvent( event )
	self.key = key
	self.meta = meta
end
