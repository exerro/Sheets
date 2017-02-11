
 -- @once
 -- @print Including sheets.elements.Button

class "Button" extends "Sheet" implements "IHasText" {
	down = false;
	colour = CYAN;
	colour_pressed = LIGHTBLUE;
	horizontal_alignment = ALIGNMENT_CENTRE;
	vertical_alignment = ALIGNMENT_CENTRE;
}

function Button:Button( x, y, width, height, text )
	self:initialise()
	self:IHasText()
	self:Sheet( x, y, width, height )

	if text then
		self:set_text( text )
	end
end

function Button:on_pre_draw()
	self.canvas:clear( self.down and self.colour_pressed or self.colour )
	self:draw_text( self.down and "pressed" or "default" )
end

function Button:on_mouse_event( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:set_changed()
	end

	if event.handled or not event:is_within_area( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		self.down = true
		self:set_changed()
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) then
		if self.on_click then
			self:on_click( event.button, event.x, event.y )
		end
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		if self.on_hold then
			self:on_hold( event.button, event.x, event.y )
		end
		event:handle()
	end
end
