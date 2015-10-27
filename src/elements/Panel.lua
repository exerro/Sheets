
class "Panel" extends "Sheet" {}

function Panel:onPreDraw()
	self.canvas:clear( self.theme:getField( self.class, "colour", "default" ) )
end

Theme.addToTemplate( Panel, "colour", {
	default = LIGHTGREY;
} )
