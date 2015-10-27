
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Sheet'
 -- @endif

 -- @print Including sheets.Sheet

-- undefined callbacks

 -- function Sheet:onPreDraw() end
 -- function Sheet:onPostDraw() end
 -- function Sheet:onUpdate( dt ) end
 -- function Sheet:onKeyboardEvent( event ) end
 -- function Sheet:onTextEvent( event ) end

class "Sheet"
	implements (IAnimation)
	implements (ICommon)
	implements (IChildContainer)
	implements (IHasParent)
	implements (IPosition)
	implements (IPositionAnimator)
{
	canvas = nil;

	handlesKeyboard = false;
	handlesText = false;
}

function Sheet:Sheet( x, y, width, height )
	if type( x ) ~= "number" then return error( "element attribute #1 'x' not a number (" .. class.type( x ) .. ")", 2 ) end
	if type( y ) ~= "number" then return error( "element attribute #2 'y' not a number (" .. class.type( y ) .. ")", 2 ) end
	if type( width ) ~= "number" then return error( "element attribute #3 'width' not a number (" .. class.type( width ) .. ")", 2 ) end
	if type( height ) ~= "number" then return error( "element attribute #4 'height' not a number (" .. class.type( height ) .. ")", 2 ) end

	self:IAnimation()
	self:IChildContainer()
	self:ICommon()
	self:IPosition( x, y, width, height )

	self.canvas = DrawingCanvas( width, height )
end

function Sheet:tostring()
	return "[Instance] " .. self.class:type() .. " " .. tostring( self.id )
end

function Sheet:onParentResized() end

function Sheet:draw()
	if self.changed then
		if self.onPreDraw then
			self:onPreDraw()
		end

		local children = self.children

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( self.canvas, child.x, child.y )
		end

		if self.onPostDraw then
			self:onPostDraw()
		end
		self.changed = false
	end
end

function Sheet:handle( event )
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
		if event:is( EVENT_MOUSE_PING ) and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then
			event.button[#event.button + 1] = self
		end
		self:onMouseEvent( event )
	elseif event:typeOf( KeyboardEvent ) and self.handlesKeyboard and self.onKeyboardEvent then
		self:onKeyboardEvent( event )
	elseif event:typeOf( TextEvent ) and self.handlesText and self.onTextEvent then
		self:onTextEvent( event )
	end
end

function Sheet:onMouseEvent( event )
	if not event.handled and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then
		if not event:is( EVENT_MOUSE_DRAG ) and not event:is( EVENT_MOUSE_SCROLL ) then
			event:handle()
		end
	end
end
