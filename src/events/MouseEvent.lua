
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.events.MouseEvent'
 -- @endif

 -- @print Including sheets.events.MouseEvent

class "MouseEvent" implements (IEvent) {
	x = 0;
	y = 0;
	button = 0;
	within = true;
}

function MouseEvent:MouseEvent( event, x, y, button, within )
	self:IEvent( event )
	self.x = x
	self.y = y
	self.button = button
	self.within = within
end

function MouseEvent:isWithinArea( x, y, width, height )
	return self.x >= x and self.y >= y and self.x < x + width and self.y < y + height
end

function MouseEvent:clone( x, y, within )
	local sub = MouseEvent( self.event, self.x - x, self.y - y, self.button, self.within and within )
	sub.handled = self.handled

	function sub.handle()
		sub.handled = true
		self:handle()
	end

	return sub
end
