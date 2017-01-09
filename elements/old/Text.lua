
 -- @once
 -- @print Including sheets.elements.Text

class "Text" extends "Sheet" implements "IHasText" {}

function Text:Text( x, y, width, height, text )
	self.text = text
	return self:Sheet( x, y, width, height )
end

function Text:on_pre_draw()
	self.canvas:clear( self.style:get "colour" )
	self:draw_text "default"
end

Style.add_to_template( Text, {
	["colour"] = WHITE;
	["text-colour"] = GREY;
	["horizontal-alignment"] = ALIGNMENT_LEFT;
	["vertical-alignment"] = ALIGNMENT_TOP;
} )
