
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.UIButton'
 -- @endif

 -- @print Including sheets.UIButton

class "UIButton" extends "Sheet" implements (ITextRenderer) {
	down = false;
	vertical_alignment = ALIGNMENT_CENTRE;
	horizontal_alignment = ALIGNMENT_CENTRE;
}

function UIButton:UIButton( x, y, width, height, text )
	self.text = text
	return self:Sheet( x, y, width, height )
end

function UIButton:onPreDraw()
	self.canvas:clear( self.theme:getField( self.class, "colour", self.down and "pressed" or "default" ) )
	self:drawText( self.down and "pressed" or "default" )
end

function UIButton:onMouseEvent( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:setChanged()
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) then
		return
	end
	event:handle()

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		self.down = true
		self:setChanged()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) and self.onClick then
		self:onClick()
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) and self.onHold then
		self:onHold()
	end
end
