
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
	self.canvas:clear( self.style:getField "colour" )
	self:drawText "default"
end

Style.addToTemplate( Text, {
	["colour"] = WHITE;
	["textColour"] = GREY;
	["horizontal-alignment"] = ALIGNMENT_LEFT;
	["vertical-alignment"] = ALIGNMENT_TOP;
} )
