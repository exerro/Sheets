
 -- @once
 -- @print Including sheets.elements.Container

-- needs to update to new exception system

class "Container" extends "Sheet" {}

function Container:Container( x, y, w, h )
	self:initialise()
	return self:Sheet( x, y, w, h )
end

function Container:draw()
	if self.changed then

		local children = self.children
		local cx, cy, cc

		self:reset_cursor_blink()

		self.canvas:clear( self.style:get "colour" )

		if self.on_pre_draw then
			self:on_pre_draw()
		end

		for i = 1, #children do
			local child = children[i]
			if child:is_visible() then
				child:draw()
				child.canvas:draw_to( self.canvas, child.x, child.y )

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
end

Style.add_to_template( Container, {
	["colour"] = WHITE;
} )
