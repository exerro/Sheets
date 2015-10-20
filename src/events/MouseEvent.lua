

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
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end
	if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end

	return self.x >= x and self.y >= y and self.x < x + width and self.y < y + height
end

function MouseEvent:clone( x, y, within )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end

	local sub = MouseEvent( self.event, self.x - x, self.y - y, self.button, self.within and within or false )
	sub.handled = self.handled

	function sub.handle()
		sub.handled = true
		self:handle()
	end

	return sub
end
