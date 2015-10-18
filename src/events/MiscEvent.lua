
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.MiscEvent'
 -- @endif

 -- @print Including sheets.events.MiscEvent

class "MiscEvent" implements (IEvent) {
	key = 0;
	meta = {};
}

function MiscEvent:MiscEvent( ... )
	self:IEvent( event )
	self.parameters = { ... }
end
