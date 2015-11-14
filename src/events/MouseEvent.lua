

 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.MouseEvent'
 -- @endif

 -- @print Including sheets.events.MouseEvent

class "MouseEvent" extends "Event" {
	event = "MouseEvent";
	x = 0;
	y = 0;
	button = 0;
	within = true;
}

function MouseEvent:MouseEvent( event, x, y, button, within )
	self.event = event
	self.x = x
	self.y = y
	self.button = button
	self.within = within
end

function MouseEvent:isWithinArea( x, y, width, height )
	functionParameters.check( 4,
		"x", "number", x,
		"y", "number", y,
		"width", "number", width,
		"height", "number", height
	)

	return self.x >= x and self.y >= y and self.x < x + width and self.y < y + height
end

function MouseEvent:clone( x, y, within )
	functionParameters.check( 2,
		"x", "number", x,
		"y", "number", y
	)

	local sub = MouseEvent( self.event, self.x - x, self.y - y, self.button, self.within and within or false )
	sub.handled = self.handled

	function sub.handle()
		sub.handled = true
		self:handle()
	end

	return sub
end
