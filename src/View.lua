
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.View'
 -- @endif

 -- @print Including sheets.View

local function childDrawSort( a, b )
	return a.z < b.z
end

class "View" implements (IChildContainer) implements (IPosition) implements (IAnimation) implements (IHasParent) implements (IPositionAnimator)
{
	id = "default";

	parent = nil;

	changed = true;

	canvas = nil;
	theme = nil;
}

function View:View( x, y, width, height )
	-- @if SHEETS_TYPE_CHECK
		if type( x ) ~= "number" then return error( "element attribute #1 'x' not a number (" .. class.type( x ) .. ")", 2 ) end
		if type( y ) ~= "number" then return error( "element attribute #2 'y' not a number (" .. class.type( y ) .. ")", 2 ) end
		if type( width ) ~= "number" then return error( "element attribute #3 'width' not a number (" .. class.type( width ) .. ")", 2 ) end
		if type( height ) ~= "number" then return error( "element attribute #4 'height' not a number (" .. class.type( height ) .. ")", 2 ) end
	-- @endif
	self:IPosition( x, y, width, height )
	self:IChildContainer()
	self:IAnimation()

	self.canvas = DrawingCanvas( width, height )
	self.theme = Theme()

	self.meta.__add = self.addChild
end

function View:tostring()
	return "[Instance] View " .. tostring( self.id )
end

function View:setID( id )
	self.id = tostring( id )
	return self
end

function View:setChanged( state )
	self.changed = state
	if state and self.parent and not self.parent.changed then
		self.parent:setChanged( true )
	end
	return self
end

function View:draw()
	if self.changed then
		local canvas = self.canvas

		canvas:clear( self.theme:getField( self.class, "colour", "default" ) )

		local children = {}
		for i = 1, #self.children do
			children[i] = self.children[i]
		end
		table.sort( children, childDrawSort )

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( canvas, child.x, child.y )
		end

		self.changed = false
	end
end

function View:update( dt )
	 -- @if SHEETS_TYPE_CHECK
		if type( dt ) ~= "number" then return error( "expected number dt, got " .. class.type( dt ) ) end
	 -- @endif
	
	self:updateAnimations( dt )

	local c = {}
	for i = 1, #self.children do
		c[i] = self.children[i]
	end

	for i = #c, 1, -1 do
		c[i]:update( dt )
	end
end

function View:handle( event )

	local c = {}
	for i = 1, #self.children do
		c[i] = self.children[i]
	end
	table.sort( c, childDrawSort )

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

end

function View:onKeyboardEvent( event )

end
