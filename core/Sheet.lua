
 -- @once
 -- @print Including sheets.core.Sheet

class "Sheet"
	implements "IAnimation"
	implements "IAttributeAnimator"
	implements "IChildContainer"
	implements "ISize"
{
	x = 0;
	y = 0;
	z = 0;

	id = "ID";
	tags = nil;
	style = nil;

	parent = nil;

	canvas = nil;
	changed = true;
	cursor_x = 0;
	cursor_y = 0;
	cursor_colour = 0;
	cursor_active = false;

	handles_keyboard = false;
	handles_text = false;
}

function Sheet:Sheet( x, y, width, height )
	parameters.check_constructor( self.class, 4,
		"x", "number", x,
		"y", "number", y,
		"width", "number", width,
		"height", "number", height
	)

	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.tags = {}

	self:IAnimation()
	self:IChildContainer()
	self.style = Style( self )

	self.canvas = DrawingCanvas( width, height )
end

function Sheet:add_tag( tag )
	self.tags[tag] = true
	return self
end

function Sheet:remove_tag( tag )
	self.tags[tag] = nil
	return self
end

function Sheet:has_tag( tag )
	return self.tags[tag] or false
end

function Sheet:set_x( x )
	parameters.check( 1, "x", "number", x )

	if self.x ~= x then
		self.x = x
		if self.parent then self.parent:set_changed( true ) end
	end
	return self
end

function Sheet:set_y( y )
	parameters.check( 1, "y", "number", y )

	if self.y ~= y then
		self.y = y
		if self.parent then self.parent:set_changed( true ) end
	end
	return self
end

function Sheet:set_z( z )
	parameters.check( 1, "z", "number", z )

	if self.z ~= z then
		self.z = z
		if self.parent then self.parent:reposition_child_z_index( self ) end
	end
	return self
end

function Sheet:set__id( id )
	self.id = tostring( id )
	return self
end

function Sheet:set_style( style, children )
	parameters.check( 1, "style", Style, style )

	self.style = style:clone( self )

	if children and self.children then
		for i = 1, #self.children do
			self.children[i]:set_style( style, true )
		end
	end

	self:set_changed( true )
	return self
end

function Sheet:set_parent( parent )
	if parent and not class.type_of( parent, Sheet ) and not class.type_of( parent, Screen ) then
		Exception.throw( IncorrectParameterException( "expected Sheet or Screen parent, got " .. class.type( parent ), 2 ) )
	end

	if parent then
		parent:add_child( self )
	else
		self:remove()
	end
	return self
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
		return self:set_parent( self.parent )
	end
	return self
end

function Sheet:set_changed( state )
	self.changed = state ~= false
	if state ~= false and self.parent and not self.parent.changed then
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

function Sheet:on_parent_resized() end

function Sheet:update( dt )
	local children = self:get_children()

	self:update_animations( dt )

	if self.on_update then
		self:on_update( dt )
	end

	for i = #children, 1, -1 do
		children[i]:update( dt )
	end
end

function Sheet:draw()
	if self.changed then

		local children = self:get_children()
		local cx, cy, cc

		self:reset_cursor_blink()

		if self.on_pre_draw then
			self:on_pre_draw()
		end

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:draw_to( self.canvas, child.x, child.y )

			if child.cursor_active then
				cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
			end
		end

		if cx then
			self:set_cursor_blink( cx, cy, cc )
		end

		if self.on_post_draw then
			self:on_post_draw()
		end

		self.changed = false
	end
end

function Sheet:handle( event )
	local children = self:get_children()

	if event:type_of( MouseEvent ) then
		local within = event:is_within_area( 0, 0, self.width, self.height )
		for i = #children, 1, -1 do
			children[i]:handle( event:clone( children[i].x, children[i].y, within ) )
		end
	else
		for i = #children, 1, -1 do
			children[i]:handle( event )
		end
	end

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
		if not event:is( EVENT_MOUSE_DRAG ) and not event:is( EVENT_MOUSE_SCROLL ) then
			event:handle( self )
		end
	end
end
