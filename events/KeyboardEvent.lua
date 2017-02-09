
 -- @once
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
	local t, segment2

	for segment in hotkey:gmatch "(.-)%-" do
		if segment == "ctrl" or segment == "shift" or segment == "alt" then
			segment = segment:sub( 1, 1 ):upper() .. segment:sub( 2 )
			segment2 = "right" .. segment
			segment = "left" .. segment

			if self.held[segment2] then
				if self.held[segment] then
					segment = self.held[segment] < self.held[segment2] and (not t or self.held[segment] > t) and segment or segment2
				else
					segment = segment2
				end
			end
		end

		if not self.held[segment] or ( t and self.held[segment] < t ) then
			return false
		end

		t = self.held[segment]
	end

	return self.key == keys[hotkey:gsub( ".+%-", "" )]
end

function KeyboardEvent:is_held( key )
	return self.key == keys[key] or self.held[key]
end
