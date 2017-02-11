
 -- @once
 -- @print Including sheets.elements.Panel

class "Panel" extends "Sheet" {
	colour = 0;
}

function Panel:Panel( x, y, w, h )
	self:initialise()
	return self:Sheet( x, y, w, h )
end

function Panel:draw( canvas, x, y )
	if self.changed then
		self:reset_cursor_blink()
		self.canvas:clear( self.colour )
		self.changed = false
	end
end
