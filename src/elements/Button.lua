
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
	self.canvas:clear( self.down and self.style:getField "colour.pressed" or self.style:getField "colour" )
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

Style.addToTemplate( Button, {
	["colour"] = CYAN;
	["colour.pressed"] = LIGHTBLUE;
	["textColour"] = WHITE;
	["textColour.pressed"] = WHITE;
	["horizontal-alignment"] = ALIGNMENT_CENTRE;
	["horizontal-alignment.pressed"] = ALIGNMENT_CENTRE;
	["vertical-alignment"] = ALIGNMENT_CENTRE;
	["vertical-alignment.pressed"] = ALIGNMENT_CENTRE;
} )
