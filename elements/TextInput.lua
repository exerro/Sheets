
 -- @include interfaces.ITextRenderer
 -- @include components.active
 -- @include components.colour
 -- @include components.text
 -- @include components.scroll
 -- @include components.padding
 -- @include components.input

 -- @print including(elements.TextInput)

@class TextInput extends Sheet {
	down = false;
	height = 1;
}

TextInput:add_components( 'active', 'colour', 'text', 'scroll', 'input', 'padding' )

function TextInput:TextInput( x, y, width, height, hint_text )
	self:Sheet( x, y, width, height )

	self:set_colour( LIGHTGREY, true )
	self:set_text_colour( GREY, true )
	self:set_active_colour( WHITE, true )
	self:set_active_text_colour( GREY, true )
	self:set_hint_text_colour( "text_colour", true )
	self:set_active_hint_text_colour( "active_text_colour", true )
	self:set_max_scroll_x( 0 )
	self:set_min_scroll_x "-(#text == 0 & #hint_text | #text) + 1"
	self:set_max_scroll_y( 0 )
	self:set_min_scroll_y( "-line_count + 1" )

	if hint_text then
		self:set_hint_text( hint_text )
	else
		self:set_hint_text( "!default", true )
	end
end

function TextInput:draw( surface, x, y )
	local bcol = self.colour
	local tcol = self.text_colour
	local text = self.text

	if self.active then
		bcol = self.active_colour
	end

	if #self.text == 0 then
		if self.active then
			tcol = self.active_hint_text_colour
		else
			tcol = self.hint_text_colour
		end
		text = self.hint_text
	elseif self.active then
		tcol = self.active_text_colour
	end

	surface:fillRect( x, y, self.width, self.height, bcol, bcol ~= nil and WHITE or nil, bcol ~= nil and " " or nil )
	surface:drawString( x, y, text:sub( 1 - self.scroll_x ):sub( 1, self.width ), bcol, tcol )
	self.changed = false
end

function TextInput:on_mouse_event( event )
	if event:is( EVENT_MOUSE_UP ) and self.down and event.button == self.down.button then
		self.down = false

	elseif event:is( EVENT_MOUSE_DRAG ) and self.down and self.down.button == event.button then
		self:set_scroll_x( self.scroll_x + event.x - self.down.x )
		self.down.x = event.x
	end

	if event.handled or not event:is_within_area( 0, 0, self.width, 1 ) or not event.within then
		if event:is( EVENT_MOUSE_DOWN ) then
			return self:set_active( false )
		end
		return
	end

	if event:is( EVENT_MOUSE_DOWN ) and not self.down then
		self.down = { button = event.button, x = event.x }
		self:set_active( true )

		return event:handle( self )
	elseif event:is( EVENT_MOUSE_CLICK ) then
		if self.on_click then
			self:on_click( event.button, event.x, event.y )
		end

		return event:handle( self )
	elseif event:is( EVENT_MOUSE_SCROLL ) then
		self:set_scroll_x( self.scroll_x + event.button )

		return event:handle( self )
	end
end
