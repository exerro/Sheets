
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.Container'
 -- @endif

 -- @print Including sheets.elements.Container

-- needs to update to new exception system

class "Container" extends "Sheet" {}

function Container:draw()
	if self.changed then

		local children = self.children
		local cx, cy, cc

		self:resetCursorBlink()

		self.canvas:clear( self.style:getField "colour" )

		if self.onPreDraw then
			self:onPreDraw()
		end

		for i = 1, #children do
			local child = children[i]
			if child:isVisible() then
				child:draw()
				child.canvas:drawTo( self.canvas, child.x, child.y )

				if child.cursor_active then
					cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
				end
			end
		end

		if cx then
			self:setCursorBlink( cx, cy, cc )
		end

		if self.onPostDraw then
			self:onPostDraw()
		end

		self.changed = false
	end
end

Style.addToTemplate( Container, {
	["colour"] = WHITE;
} )
