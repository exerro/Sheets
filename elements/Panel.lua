
 -- @once
 -- @print Including sheets.elements.Panel

class "Panel" extends "Sheet" {}

function Panel:on_pre_draw()
	self.canvas:clear( self.style:get "colour" )
end

Style.add_to_template( Panel, {
	["colour"] = LIGHTGREY;
} )
