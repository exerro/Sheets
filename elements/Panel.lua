
 -- @include components.colour

 -- @print including(elements.Panel)

@class Panel extends Sheet {
	colour = nil;
}

Panel:add_components( 'colour' )

function Panel:draw( canvas, x, y )
	canvas:fillRect( x, y, self.width, self.height, self.colour, WHITE, " " )
end
