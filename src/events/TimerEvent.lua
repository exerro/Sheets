
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.TimerEvent'
 -- @endif

 -- @print Including sheets.events.TimerEvent

class "TimerEvent" implements (IEvent) {
	key = 0;
	meta = {};
}

function TimerEvent:TimerEvent( timerID )
	self:IEvent( SHEETS_EVENT_TIMER )
	self.timerID = timerID
end
