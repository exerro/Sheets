
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
	if type( x ) ~= "number" then return error( "element attribute #1 'x' not a number (" .. class.type( x ) .. ")", 2 ) end
	if type( y ) ~= "number" then return error( "element attribute #2 'y' not a number (" .. class.type( y ) .. ")", 2 ) end
	if type( width ) ~= "number" then return error( "element attribute #3 'width' not a number (" .. class.type( width ) .. ")", 2 ) end
	if type( height ) ~= "number" then return error( "element attribute #4 'height' not a number (" .. class.type( height ) .. ")", 2 ) end

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
		local canvas = self.canvas

		canvas:clear( self.theme:getField( self.class, "colour", "default" ) )

		local children = self.children

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( canvas, child.x, child.y )
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

	if event:typeOf( MouseEvent ) then
		self:onMouseEvent( event )
	elseif event:typeOf( KeyboardEvent ) then
		self:onKeyboardEvent( event )
	end
end

function View:onMouseEvent( event )
	-- click callbacks
end

function View:onKeyboardEvent( event )
	-- keyboard shortcut callbacks
end

Theme.addToTemplate( View, "colour", {
	default = WHITE;
} )
