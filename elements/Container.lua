
 -- @include components.colour
 -- @include components.offset

 -- @print including(elements.Container)

@class Container extends Sheet implements IChildContainer {
	on_pre_draw = nil;
	on_post_draw = nil;
}

Container:add_components( 'colour', 'offset' )

function Container:Container( x, y, w, h )
	self:Sheet( x, y, w, h )
	
	self:ICollatedChildren()
	self:IQueryable()
	self:IChildContainer()
end

function Container:update( dt )
	local children = self:get_children()

	self.values:update( dt )

	if self.on_update then
		self:on_update( dt )
	end

	for i = #children, 1, -1 do
		children[i]:update( dt )
	end
end

function Container:draw( surface, x, y )
	local children = self.children
	local cx, cy, cc
	local x_offset, y_offset = self.x_offset, self.y_offset

	self:reset_cursor_blink()
	surface:fillRect( x, y, self.width, self.height, self.colour )

	if self.on_pre_draw then
		self:on_pre_draw()
	end

	for i = 1, #children do
		local child = children[i]
		if child:is_visible() then
			child:draw( surface, x + child.x + x_offset, y + child.y + y_offset )

			if child.cursor_active then
				cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
			end
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

function Container:handle( event )
	local children = self:get_children()
	local x_offset, y_offset = self.x_offset, self.y_offset

	if event:type_of( MouseEvent ) then
		local within = event:is_within_area( 0, 0, self.width, self.height )
		for i = #children, 1, -1 do
			children[i]:handle( event:clone( children[i].x + x_offset, children[i].y + y_offset, within ) )
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
