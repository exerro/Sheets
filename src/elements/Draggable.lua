
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'test.elements.Draggable'
 -- @endif

 -- @print Including test.elements.Draggable

class "Draggable" extends "Sheet" implements (IHasText) {
	down = false;
}

function Draggable:Draggable( x, y, width, height, text )
	self.text = text
	return self:Sheet( x, y, width, height )
end

function Draggable:onPreDraw()
	self.canvas:clear( self.down and BLUE or CYAN )
	self:drawText( self.down and "pressed" or "default" )
end

function Draggable:onMouseEvent( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		if self.onDrop then
			self:onDrop( self.down.x, self.down.y )
		end
		self.down = false
		self:setChanged()
	elseif self.down and event:is( SHEETS_EVENT_MOUSE_DRAG ) and not event.handled and event.within then
		self:setX( self.x + event.x - self.down.x )
		self:setY( self.y + event.y - self.down.y )
		if self.onDrag then
			self:onDrag()
		end
		event:handle()
		return
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		if self.onPickUp then
			self:onPickUp()
		end
		self.down = { x = event.x, y = event.y }
		self:setChanged()
		self:bringToFront()
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) then
		if self.onClick then
			self:onClick( event.button, event.x, event.y )
		end
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		if self.onHold then
			self:onHold( event.button, event.x, event.y )
		end
		event:handle()
	end
end

Style.addToTemplate( Draggable, {
	["colour"] = CYAN;
	["colour.pressed"] = LIGHTBLUE;
	["textColour"] = WHITE;
	["textColour.pressed"] = WHITE;
	["horizontal-alignment"] = ALIGNMENT_CENTRE;
	["horizontal-alignment.pressed"] = ALIGNMENT_CENTRE;
	["vertical-alignment"] = ALIGNMENT_CENTRE;
	["vertical-alignment.pressed"] = ALIGNMENT_CENTRE;
} )
