
 -- @once
 -- @print Including sheets.elements.Checkbox

class "Checkbox" extends "Sheet" {
	down = false;
	checked = false;
}

function Checkbox:Checkbox( x, y, checked )
	self.checked = checked
	self:Sheet( x, y, 1, 1 )
end

function Checkbox:set_width() end
function Checkbox:set_height() end

function Checkbox:toggle()
	self.checked = not self.checked
	if self.on_toggle then
		self:on_toggle()
	end
	if self.checked and self.on_check then
		self:on_check()
	elseif not self.checked and self.on_uncheck then
		self:on_uncheck()
	end
	self:set_changed()
end

function Checkbox:on_pre_draw()
	self.canvas:draw_point( 0, 0, {
		colour = self.style:get( "colour." .. ( ( self.down and "pressed" ) or ( self.checked and "checked" ) or "default" ) );
		text_colour = self.style:get( "check-colour." .. ( self.down and "pressed" or "default" ) );
		character = self.checked and "x" or " ";
	} )
end

function Checkbox:on_mouse_event( event )
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
		self:toggle()
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		event:handle()
	end
end

Style.add_to_template( Checkbox, {
	["colour"] = LIGHTGREY;
	["colour.checked"] = LIGHTGREY;
	["colour.pressed"] = GREY;
	["check-colour"] = BLACK;
	["check-colour.pressed"] = LIGHTGREY;
} )
