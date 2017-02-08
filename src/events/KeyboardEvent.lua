
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.KeyboardEvent'
 -- @endif

 -- @print Including sheets.events.KeyboardEvent

class "KeyboardEvent" extends "Event" {
	event = "KeyboardEvent";
	key = 0;
	held = {};
}

function KeyboardEvent:KeyboardEvent( event, key, held )
	self.event = event
	self.key = key
	self.held = held
end

function KeyboardEvent:matches( hotkey )
	local t

	for segment in hotkey:gmatch "(.*)%-" do
		if not self.held[segment] or ( t and self.held[segment] < t ) then
			return false
		end
		t = self.held[segment]
	end

	return self.key == keys[hotkey:gsub( ".+%-", "" )]
end

function KeyboardEvent:isHeld( key )
	return self.key == keys[key] or self.held[key]
end
