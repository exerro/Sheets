
 -- @include interfaces.ITextRenderer
 -- @include components.active
 -- @include components.colour
 -- @include components.text

 -- @print including(elements.Draggable)

@class Draggable extends Sheet implements ITextRenderer {
	down = false;
}

Draggable:add_components( 'active', 'colour', 'text' )

function Draggable:Draggable( x, y, width, height, text )
	self:Sheet( x, y, width, height )

	self:ITextRenderer()

	self:set_colour( CYAN, true )
	self:set_text_colour( WHITE, true )
	self:set_active_colour( LIGHTBLUE, true )
	self:set_active_text_colour( WHITE, true )
	self:set_horizontal_alignment( ALIGNMENT_CENTRE, true )
	self:set_vertical_alignment( ALIGNMENT_CENTRE, true )

	if text then
		self:set_text( text )
	end

	self:set_active_text "!text"
end

function Draggable:cancel_drag()
	self.down = false
	self:set_active( false )
end

function Draggable:draw( surface, x, y )
	local col = self.colour

	if self.down then
		col = self.active_colour
	end

	surface:fillRect( x, y, self.width, self.height, col, col ~= nil and WHITE or nil, col ~= nil and " " or nil )
	self:draw_text( surface, x, y )
	self.changed = false
end

function Draggable:on_mouse_event( event )
	if event:is( EVENT_MOUSE_UP ) and self.down and event.button == self.down.button then
		self.down = false
		self:set_active( false )

		return self:set_changed()

	elseif event:is( EVENT_MOUSE_DRAG ) and self.down and event.button == self.down.button then
		if event.x ~= self.down.x then
			self:set_x( self.x + event.x - self.down.x )
		end
		if event.y ~= self.down.y then
			self:set_y( self.y + event.y - self.down.y )
		end

		if self.on_drag then
			self:on_drag( event.x - self.down.x, event.y - self.down.y )
		end

		return event:handle( self )
	end

	if event.handled or not event:is_within_area( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( EVENT_MOUSE_DOWN ) and not self.down then
		self.down = { button = event.button, x = event.x, y = event.y }
		self:set_active( true )
		self:set_changed()

		return event:handle( self )
	elseif event:is( EVENT_MOUSE_CLICK ) then
		if self.on_click then
			self:on_click( event.button, event.x, event.y )
		end

		return event:handle( self )
	elseif event:is( EVENT_MOUSE_HOLD ) and self.down and event.button == self.down.button then
		if self.on_hold then
			self:on_hold( event.button, event.x, event.y )
		end

		return event:handle( self )
	end
end
