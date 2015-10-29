
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.Button'
 -- @endif

 -- @print Including sheets.elements.Button

class "Button" extends "Sheet" implements (IHasText) {
	down = false;
}

function Button:Button( x, y, width, height, text )
	self.text = text
	return self:Sheet( x, y, width, height )
end

function Button:onPreDraw()
	self.canvas:clear( self.theme:getField( self.class, "colour", self.down and "pressed" or "default" ) )
	self:drawText( self.down and "pressed" or "default" )
end

function Button:onMouseEvent( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:setChanged()
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		self.down = true
		self:setChanged()
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

Theme.addToTemplate( Button, "colour", {
	default = CYAN;
	pressed = LIGHTBLUE;
} )
Theme.addToTemplate( Button, "textColour", {
	default = WHITE;
	pressed = WHITE;
} )

Theme.addToTemplate( Button, "horizontal-alignment", {
	default = ALIGNMENT_CENTRE;
	pressed = ALIGNMENT_CENTRE;
} )
Theme.addToTemplate( Button, "vertical-alignment", {
	default = ALIGNMENT_CENTRE;
	pressed = ALIGNMENT_CENTRE;
} )
