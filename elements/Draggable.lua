
 -- @once
 -- @print Including sheets.elements.Draggable

class "Draggable" extends "Sheet" implements "IHasText" {
	down = false;
}

function Draggable:Draggable( x, y, width, height, text )
	self.text = text
	return self:Sheet( x, y, width, height )
end

function Draggable:on_pre_draw()
	self.canvas:clear( self.down and self.style:get "colour.pressed" or self.style:get "colour" )
	self:draw_text( self.down and "pressed" or "default" )
end

function Draggable:on_mouse_event( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		if self.on_drop then
			self:on_drop( self.down.x, self.down.y )
		end
		self.down = false
		self:set_changed()
	elseif self.down and event:is( SHEETS_EVENT_MOUSE_DRAG ) and not event.handled and event.within then
		self:setX( self.x + event.x - self.down.x )
		self:setY( self.y + event.y - self.down.y )
		if self.on_drag then
			self:on_drag()
		end
		event:handle()
		return
	end

	if event.handled or not event:is_within_area( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		if self.on_pickup then
			self:on_pickup()
		end
		self.down = { x = event.x, y = event.y }
		self:set_changed()
		self:bring_to_front()
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

Style.add_to_template( Draggable, {
	["colour"] = CYAN;
	["colour.pressed"] = LIGHTBLUE;
	["text-colour"] = WHITE;
	["text-colour.pressed"] = WHITE;
	["horizontal-alignment"] = ALIGNMENT_CENTRE;
	["horizontal-alignment.pressed"] = ALIGNMENT_CENTRE;
	["vertical-alignment"] = ALIGNMENT_CENTRE;
	["vertical-alignment.pressed"] = ALIGNMENT_CENTRE;
} )
