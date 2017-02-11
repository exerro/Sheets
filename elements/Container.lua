
 -- @once
 -- @print Including sheets.elements.Container

-- needs to update to new exception system

class "Container" extends "Sheet" implements "IChildContainer" {
	colour = 0;
	offset_x = 0;
	offset_y = 0;

	on_pre_draw = nil;
	on_post_draw = nil;
}

function Container:Container( x, y, w, h )
	self:initialise()
	self:ICollatedChildren()
	self:IQueryable()
	self:IChildContainer()

	return self:Sheet( x, y, w, h )
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
	local offset_x, offset_y = self.offset_x, self.offset_y

	self:reset_cursor_blink()
	surface:fillRect( x, y, self.width, self.height, self.colour )

	if self.on_pre_draw then
		self:on_pre_draw()
	end

	for i = 1, #children do
		local child = children[i]
		if child:is_visible() then
			child:draw( surface, x + child.x + offset_x, y + child.y + offset_y )

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
	local offset_x, offset_y = self.offset_x, self.offset_y

	if event:type_of( MouseEvent ) then
		local within = event:is_within_area( 0, 0, self.width, self.height )
		for i = #children, 1, -1 do
			children[i]:handle( event:clone( children[i].x + offset_x, children[i].y + offset_y, within ) )
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
