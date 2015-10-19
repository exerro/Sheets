
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
	elseif event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		event:handle()
	end
end

Theme.addToTemplate( UIButton, "colour", {
	default = CYAN;
	pressed = LIGHTBLUE;
} )
Theme.addToTemplate( UIButton, "textColour", {
	default = WHITE;
	pressed = WHITE;
} )

local decoder = SMLNodeDecoder()

decoder.isBodyAllowed = false
decoder.isBodyNecessary = false

decoder:implement( IPositionAttributes )
decoder:implement( ICommonAttributes )

function decoder:init()
	return UIButton( 0, 0, 10, 3 )
end

function decoder:attribute_text( text )
	self:setText( text )
end

SMLEnvironment:addElement( "button", UIButton, decoder )
