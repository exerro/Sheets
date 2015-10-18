
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.MouseEvent'
 -- @endif

 -- @print Including sheets.events.MouseEvent

class "MouseEvent" implements (IEvent) {
	
}

function MouseEvent:MouseEvent()
	self:IEvent()
end
