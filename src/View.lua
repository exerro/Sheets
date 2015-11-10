
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.View'
 -- @endif

 -- @print Including sheets.View

class "View"
	implements (IChildContainer)
	implements (IPosition)
	implements (IAnimation)
	implements (IHasParent)
	implements (IPositionAnimator)
	implements (ICommon)
{
	canvas = nil;
}

function View:View( x, y, width, height )
	functionParameters.checkConstructor( self.class, 4,
		"x", "number", x,
		"y", "number", y,
		"width", "number", width,
		"height", "number", height
	)

	self:IPosition( x, y, width, height )
	self:IChildContainer()
	self:IAnimation()
	self:ICommon()

	self.canvas = DrawingCanvas( width, height )
end

function View:tostring()
	return "[Instance] View " .. tostring( self.id )
end

function View:draw()
	if self.changed then

		local children = self.children
		local canvas = self.canvas
		local cx, cy, cc

		self:resetCursorBlink()
		canvas:clear( self.style:getField "colour" )

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( canvas, child.x, child.y )
			
			if child.cursor_active then
				cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
			end
		end

		if cx then
			self:setCursorBlink( cx, cy, cc )
		end

		self.changed = false
	end
end

function View:handle( event )
	local c = {}
	local children = self.children

	for i = 1, #children do
		c[i] = children[i]
	end

	if event:typeOf( MouseEvent ) then
		local within = event:isWithinArea( 0, 0, self.width, self.height )
		for i = #c, 1, -1 do
			c[i]:handle( event:clone( c[i].x, c[i].y, within ) )
		end
	else
		for i = #c, 1, -1 do
			c[i]:handle( event )
		end
	end
end

Style.addToTemplate( View, {
	colour = WHITE;
} )
