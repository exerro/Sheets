
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
	canvas:fillRect( x, y, self.width, self.height, self.colour, WHITE, " " )
end
