
 -- @once
 -- @print Including sheets.elements.Panel

class "Panel" extends "Sheet" {}

function Panel:Panel( x, y, w, h )
	self:initialise()
	return self:Sheet( x, y, w, h )
end

function Panel:on_pre_draw()
	self.canvas:clear( self.style:get "colour" )
end

Style.add_to_template( Panel, {
	["colour"] = LIGHTGREY;
} )
