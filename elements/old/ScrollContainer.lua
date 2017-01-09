
 -- @once
 -- @print Including sheets.elements.ScrollContainer

-- needs to update to new exception system

class "ScrollContainer" extends "Sheet" {
	scrollX = 0;
	scrollY = 0;

	horizontal_padding = 0;
	vertical_padding = 0;

	held_scrollbar = false;
	down = false;
}

function ScrollContainer:ScrollContainer( x, y, width, height, element )
	if class.type_of( x, Sheet ) then
		element = x
		x, y, width, height = x.x, x.y, x.width, x.height
		element.x, element.y = 0, 0
	end

	parameters.check_constructor( self.class, 4,
		"x", "number", x,
		"y", "number", y,
		"width", "number", width,
		"height", "number", height,
		"element", element and Sheet, element
	)

	self:Sheet( x, y, width, height )

	if element then
		self:add_child( element )
	end
end

function ScrollContainer:set_scroll_x( scroll )
	parameters.check( 1, "scroll", "number", scroll )

	self.scrollX = scroll
	return self:set_changed()
end

function ScrollContainer:set_scroll_y( scroll )
	parameters.check( 1, "scroll", "number", scroll )

	self.scrollY = scroll
	return self:set_changed()
end

function ScrollContainer:get_content_width()
	local width = self.horizontal_padding
	local children = self.children

	for i = 1, #self.children do
		local child_width = children[i].x + children[i].width + self.horizontal_padding
		if child_width > width then
			width = child_width
		end
	end

	return width
end

function ScrollContainer:get_content_height()
	local height = self.vertical_padding
	local children = self.children

	for i = 1, #self.children do
		local child_width = children[i].y + children[i].height + self.vertical_padding
		if child_width > height then
			height = child_width
		end
	end

	return height
end

function ScrollContainer:get_display_width( h, v )
	return v and self.width - 1 or self.width
end

function ScrollContainer:get_display_height( h, v )
	return h and self.height - 1 or self.height
end

function ScrollContainer:get_active_scrollbars( c_width, c_height )
	if c_width > self.width or c_height > self.height then
		return c_width >= self.width, c_height >= self.height
	end
	return false, false
end

function ScrollContainer:get_scrollbar_sizes( c_width, c_height, horizontal, vertical )
	return math.floor( self:get_display_width( horizontal, vertical ) / c_width * self:get_display_width( horizontal, vertical ) + .5 ), math.floor( self:get_display_height( horizontal, vertical ) / c_height * self.height + .5 )
end

function ScrollContainer:get_scrollbar_positions( c_width, c_height, horizontal, vertical )
	return math.floor( self.scrollX / c_width * self:get_display_width( horizontal, vertical ) + .5 ), math.floor( self.scrollY / c_height * self.height + .5 )
end

function ScrollContainer:draw()
	if self.changed then

		local children = self.children
		local cx, cy, cc
		local ox, oy = self.scrollX, self.scrollY

		self:reset_cursor_blink()

		if self.on_pre_draw then
			self:on_pre_draw()
		end

		for i = 1, #children do
			local child = children[i]
			if child:is_visible() then
				child:draw()
				child.canvas:draw_to( self.canvas, child.x - ox, child.y - oy )

				if child.cursor_active then
					cx, cy, cc = child.x + child.cursor_x - ox, child.y + child.cursor_y - oy, child.cursor_colour
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
end

function ScrollContainer:handle( event )
	local c = {}
	local ox, oy = self.scrollX, self.scrollY
	local children = self.children
	for i = 1, #children do
		c[i] = children[i]
	end

	if self.down and event:is( SHEETS_EVENT_MOUSE_UP ) then
		self.down = false
		self.held_scrollbar = false
		self:set_changed()
		event:handle()
	elseif self.down and event:is( SHEETS_EVENT_MOUSE_DRAG ) then
		local c_width, c_height = self:get_content_width(), self:get_content_height()
		local h, v = self:get_active_scrollbars( c_width, c_height )

		if self.held_scrollbar == "h" then
			self.scrollX = math.max( math.min( math.floor( ( event.x - self.down ) / self:get_display_width( h, v ) * c_width ), c_width - self:get_display_width( h, v ) ), 0 )
			self:set_changed()
			event:handle()
		elseif self.held_scrollbar == "v" then
			self.scrollY = math.max( math.min( math.floor( ( event.y - self.down ) / self.height * c_height ), c_height - self:get_display_height( h, v ) ), 0 )
			self:set_changed()
			event:handle()
		end
	end

	if event:type_of( MouseEvent ) and not event.handled and event:is_within_area( 0, 0, self.width, self.height ) and event.within then
		local c_width, c_height = self:get_content_width(), self:get_content_height()
		local h, v = self:get_active_scrollbars( c_width, c_height )

		if event:is( SHEETS_EVENT_MOUSE_DOWN ) then
			if event.x == self.width - 1 and v then
				local px, py = self:get_scrollbar_positions( c_width, c_height, h, v )
				local sx, sy = self:get_scrollbar_sizes( c_width, c_height, h, v )
				local down = event.y

				if down < px then
					self.scrollY = math.floor( down / self.height * c_height )
					down = 0
				elseif down >= px + sx then
					self.scrollY = math.floor( ( down - sy + 1 ) / self.height * c_height )
					down = sy - 1
				else
					down = down - py
				end

				self.held_scrollbar = "v"
				self.down = down
				self:set_changed()
				event:handle()
			elseif event.y == self.height - 1 and h then
				local px, py = self:get_scrollbar_positions( c_width, c_height, h, v )
				local sx, sy = self:get_scrollbar_sizes( c_width, c_height, h, v )
				local down = event.x

				if down < px then
					self.scrollX = math.floor( down / self:get_display_width( h, v ) * c_width )
					down = 0
				elseif down >= px + sx then
					self.scrollX = math.floor( ( down - sx + 1 ) / self:get_display_width( h, v ) * c_width )
					down = sx - 1
				else
					down = down - px
				end

				self.held_scrollbar = "h"
				self.down = down
				self:set_changed()
				event:handle()
			end
		elseif event:is( SHEETS_EVENT_MOUSE_SCROLL ) then
			if v then
				self:set_scroll_y( math.max( math.min( oy + event.button, c_height - self:get_display_height( h, v ) ), 0 ) )
			elseif h then
				self:set_scroll_x( math.max( math.min( ox + event.button, c_width - self:get_display_width( h, v ) ), 0 ) )
			end
		elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) or event:is( SHEETS_EVENT_MOUSE_HOLD ) then
			if event.x == self.width - 1 and v or event.y == self.height - 1 and h then
				event:handle()
			end
		end
	end

	if event:type_of( MouseEvent ) then
		local within = event:is_within_area( 0, 0, self.width, self.height )
		for i = #c, 1, -1 do
			c[i]:handle( event:clone( c[i].x - ox, c[i].y - oy, within ) )
		end
	else
		for i = #c, 1, -1 do
			c[i]:handle( event )
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

function ScrollContainer:on_pre_draw()
	self.canvas:clear( self.style:get "colour" )
end

function ScrollContainer:on_post_draw()
	local c_width, c_height = self:get_content_width(), self:get_content_height()
	local h, v = self:get_active_scrollbars( c_width, c_height )
	if h or v then
		local px, py = self:get_scrollbar_positions( c_width, c_height, h, v )
		local sx, sy = self:get_scrollbar_sizes( c_width, c_height, h, v )

		if h then
			local c1 = self.style:get "horizontal-bar"
			local c2 = self.held_scrollbar == "h" and
					   self.style:get "horizontal-bar.active"
					or self.style:get "horizontal-bar.bar"

			self.canvas:map_colour( self.canvas:get_area( GRAPHICS_AREA_HLINE, 0, self.height - 1, self:get_display_width( h, v ) ), c1 )
			self.canvas:map_colour( self.canvas:get_area( GRAPHICS_AREA_HLINE, px, self.height - 1, sx ), c2 )
		end
		if v then
			local c1 = self.style:get "vertical-bar"
			local c2 = self.held_scrollbar == "v" and
					   self.style:get "vertical-bar.active"
					or self.style:get "vertical-bar.bar"

			self.canvas:map_colour( self.canvas:get_area( GRAPHICS_AREA_VLINE, self.width - 1, 0, self.height ), c1 )
			self.canvas:map_colour( self.canvas:get_area( GRAPHICS_AREA_VLINE, self.width - 1, py, sy ), c2 )
		end
	end
end

function ScrollContainer:get_children_at( x, y )
	parameters.check( 2, "x", "number", x, "y", "number", y )

	local c = {}
	local ox, oy = self.scrollX, self.scrollY

	local children = self.children
	for i = 1, #children do
		c[i] = children[i]
	end

	local elements = {}

	for i = #c, 1, -1 do
		c[i]:handle( MouseEvent( EVENT_MOUSE_PING, x - c[i].x - ox, y - c[i].y - oy, elements, true ) )
	end

	return elements
end

function ScrollContainer:is_child_visible( child )
	parameters.check( 1, "child", Sheet, child )

	local ox, oy = self.scrollX, self.scrollY

	return child.x + child.width - ox > 0 and child.y + child.height - oy > 0 and child.x - ox < self.width and child.y - oy < self.height
end

Style.add_to_template( ScrollContainer, {
	["colour"] = WHITE;
	["horizontal-bar"] = GREY;
	["horizontal-bar.bar"] = LIGHTGREY;
	["horizontal-bar.active"] = LIGHTBLUE;
	["vertical-bar"] = GREY;
	["vertical-bar.bar"] = LIGHTGREY;
	["vertical-bar.active"] = LIGHTBLUE;
} )
