
 -- @once
 -- @print Including sheets.elements.ClippedContainer

class "ClippedContainer" extends "Container" {
	surface = nil;
	colour = WHITE;
}

function ClippedContainer:ClippedContainer( ... )
	self.surface = surface.create( 0, 0 )

	return self:Container( ... )
end

function ClippedContainer:draw( surface, x, y )
	if self.changed then
		local children = self.children
		local cx, cy, cc
		local offset_x, offset_y = self.offset_x, self.offset_y

		self:reset_cursor_blink()
		self.surface:clear( self.colour )

		if self.on_pre_draw then
			self:on_pre_draw()
		end

		for i = 1, #children do
			local child = children[i]
			if child:is_visible() then
				child:draw( self.surface, child.x + offset_x, child.y + offset_y )

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

	surface:drawSurface( self.surface, x, y )
end
