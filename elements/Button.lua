
 -- @once
 -- @print Including sheets.elements.Button

class "Button" extends "Sheet" implements "IHasText" implements "IColoured" {
	down = false;
	colour = nil;
	active_colour = nil;
	horizontal_alignment = ALIGNMENT_CENTRE;
	vertical_alignment = ALIGNMENT_CENTRE;
}

function Button:Button( x, y, width, height, text )
	self:initialise()
	self:IHasText()
	self:IColoured()
	self.values:add( "active_colour", LIGHTBLUE )
	self:Sheet( x, y, width, height )

	self:set_colour( CYAN )
	self:set_horizontal_alignment( ALIGNMENT_CENTRE )
	self:set_vertical_alignment( ALIGNMENT_CENTRE )

	if text then
		self:set_text( text )
	end
end

function Button:draw( surface, x, y )
	surface:fillRect( x, y, self.width, self.height, self.down and self.active_colour or self.colour, WHITE, " " )
	self:draw_text( surface, x, y )
	self.changed = false
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
