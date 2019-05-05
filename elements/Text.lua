
 -- @include interfaces.ITextRenderer
 -- @include components.colour
 -- @include components.text

 -- @print including(elements.Text)

@class Text extends Sheet implements ITextRenderer {
	down = false;
}

Text:add_components( 'colour', 'text' )

function Text:Text( x, y, width, height, text )
	self:Sheet( x, y, width, height )

	self:ITextRenderer()

	self:set_colour( CYAN, true )
	self:set_text_colour( WHITE, true )
	self:set_horizontal_alignment( ALIGNMENT_LEFT, true )
	self:set_vertical_alignment( ALIGNMENT_TOP, true )

	if text then
		self:set_text( text )
	end
end

function Text:draw( surface, x, y )
	surface:fillRect( x, y, self.width, self.height, self.colour, self.colour ~= nil and WHITE or nil, self.colour ~= nil and " " or nil )
	self:draw_text( surface, x, y )
	self.changed = false
end
