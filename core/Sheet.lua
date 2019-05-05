
 -- @include interfaces.IComponent
 -- @include components.parent
 -- @include components.position
 -- @include components.size
 -- @include interfaces.IThemed

 -- @print including(core.Sheet)

@class Sheet implements IComponent, ITagged, IThemed {
	x = 0;
	y = 0;
	z = 0;

	style = nil;

	parent = nil;

	-- internal
	changed = true;
	cursor_x = 0;
	cursor_y = 0;
	cursor_colour = 0;
	cursor_active = false;
	handles_keyboard = false;
	handles_text = false;
	values = nil;
}

Sheet:add_components( 'parent', 'position', 'size' )

function Sheet:Sheet( x, y, width, height )
	self:initialise_properties()
	self:ITagged()
	self:IThemed()

	if x ~= nil then self:set_x( x ) end
	if y ~= nil then self:set_y( y ) end
	if width ~= nil then self:set_width( width ) end
	if height ~= nil then self:set_height( height ) end
end

function Sheet:remove()
	if self.parent then
		return self.parent:remove_child( self )
	end
end

function Sheet:is_visible()
	return self.parent and self.parent:is_child_visible( self )
end

function Sheet:bring_to_front()
	if self.parent then
		return self:set_parent( self.parent ) -- TODO: improve this
	end
	return self
end

function Sheet:set_changed( state )
	self.changed = state ~= false
	if state ~= false and self.parent and not self.parent.changed then -- TODO: why not self.parent.changed?
		self.parent:set_changed()
	end
	return self
end

function Sheet:set_cursor_blink( x, y, colour )
	colour = colour or GREY

	parameters.check( 3, "x", "number", x, "y", "number", y, "colour", "number", colour )

	self.cursor_active = true
	self.cursor_x = x
	self.cursor_y = y
	self.cursor_colour = colour

	return self
end

function Sheet:reset_cursor_blink()
	self.cursor_active = false
	return self
end

function Sheet:tostring()
	return "[Instance] " .. self.class:type() .. " " .. tostring( self.id )
end

function Sheet:update( dt )
	self.values:update( dt )

	if self.on_update then
		self:on_update( dt )
	end
end

function Sheet:draw( surface, x, y )
	self.changed = false
end

function Sheet:handle( event )
	if event:type_of( MouseEvent ) then
		if event:is( EVENT_MOUSE_PING ) and event:is_within_area( 0, 0, self.width, self.height ) and event.within then
			event.button[#event.button + 1] = self
		end
		self:on_mouse_event( event )
	elseif event:type_of( KeyboardEvent ) and self.handles_keyboard and self.on_keyboard_event then
		self:on_keyboard_event( event )
	elseif event:type_of( TextEvent ) and self.handles_text and self.on_text_event then
		self:on_text_event( event )
	end
end

function Sheet:on_mouse_event( event )
	if not event.handled and event:is_within_area( 0, 0, self.width, self.height ) and event.within then
		if event:is( EVENT_MOUSE_DOWN ) then
			return event:handle( self )
		end
	end
end
