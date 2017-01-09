
 -- @once
 -- @print Including sheets.elements.Button

class "Button" extends "Sheet" implements "IHasText" {
	down = false;
}

function Button:Button( x, y, width, height, text )
	parameters.check_constructor( self.class, 5,
		"x", "number", x,
		"y", "number", y,
		"width", "number", width,
		"height", "number", height,
		"text", "string", text == nil and "" or text
	)

	self:Sheet( x, y, width, height )
	self:IHasText()

	if text then
		self:set_text( text )
	end
end

function Button:on_pre_draw()
	self.canvas:clear( self.down and self.style:get "colour.pressed" or self.style:get "colour" )
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

Style.add_to_template( Button, {
	["colour"] = CYAN;
	["colour.pressed"] = LIGHTBLUE;
	["text-colour"] = WHITE;
	["text-colour.pressed"] = WHITE;
	["horizontal-alignment"] = ALIGNMENT_CENTRE;
	["horizontal-alignment.pressed"] = ALIGNMENT_CENTRE;
	["vertical-alignment"] = ALIGNMENT_CENTRE;
	["vertical-alignment.pressed"] = ALIGNMENT_CENTRE;
} )
