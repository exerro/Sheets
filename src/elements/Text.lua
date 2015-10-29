
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.Text'
 -- @endif

 -- @print Including sheets.elements.Text

class "Text" extends "Sheet" implements (IHasText) {}

function Text:Text( x, y, width, height, text )
	self.text = text
	return self:Sheet( x, y, width, height )
end

function Text:onPreDraw()
	self.canvas:clear( self.theme:getField( self.class, "colour", "default" ) )
	self:drawText "default"
end

Theme.addToTemplate( Text, "colour", {
	default = WHITE;
} )
Theme.addToTemplate( Text, "textColour", {
	default = GREY;
} )

Theme.addToTemplate( Text, "horizontal-alignment", {
	default = ALIGNMENT_LEFT;
} )
Theme.addToTemplate( Text, "vertical-alignment", {
	default = ALIGNMENT_TOP;
} )
