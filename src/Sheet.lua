
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
	implements "IAnimation"
	implements "IAttributeAnimator"
	implements "IChildContainer"
	implements "ISize"
{
	x = 0;
	y = 0;
	z = 0;

	id = "ID";
	style = nil;

	parent = nil;

	canvas = nil;
	changed = true;
	cursor_x = 0;
	cursor_y = 0;
	cursor_colour = 0;
	cursor_active = false;

	handlesKeyboard = false;
	handlesText = false;
}

function Sheet:Sheet( x, y, width, height )
	functionParameters.checkConstructor( self.class, 4,
		"x", "number", x,
		"y", "number", y,
		"width", "number", width,
		"height", "number", height
	)

	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self:IAnimation()
	self:IChildContainer()
	self.style = Style( self )

	self.canvas = DrawingCanvas( width, height )
end

function Sheet:setX( x )
	functionParameters.check( 1, "x", "number", x )
	
	if self.x ~= x then
		self.x = x
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function Sheet:setY( y )
	functionParameters.check( 1, "y", "number", y )
	
	if self.y ~= y then
		self.y = y
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function Sheet:setZ( z )
	functionParameters.check( 1, "z", "number", z )

	if self.z ~= z then
		self.z = z
		if self.parent then self.parent:repositionChildZIndex( self ) end
	end
	return self
end

function Sheet:setID( id )
	self.id = tostring( id )
	return self
end

function Sheet:setStyle( style, children )
	functionParameters.check( 1, "style", Style, style )

	self.style = style:clone( self )
	
	if children and self.children then
		for i = 1, #self.children do
			self.children[i]:setStyle( style, true )
		end
	end

	self:setChanged( true )
	return self
end

function Sheet:setParent( parent )
	-- fix this
	if parent and ( not class.isInstance( parent ) or not parent:implements( IChildContainer ) ) then return error( "expected IChildContainer parent, got " .. class.type( parent ) ) end

	if parent then
		parent:addChild( self )
	else
		self:remove()
	end
	return self
end

function Sheet:remove()
	if self.parent then
		return self.parent:removeChild( self )
	end
end

function Sheet:isVisible()
	return self.parent and self.parent:isChildVisible( self )
end

function Sheet:bringToFront()
	if self.parent then
		return self:setParent( self.parent )
	end
	return self
end

function Sheet:setChanged( state )
	self.changed = state ~= false
	if state ~= false and self.parent and not self.parent.changed then
		self.parent:setChanged()
	end
	return self
end

function Sheet:setCursorBlink( x, y, colour )
	colour = colour or GREY

	functionParameters.check( 3, "x", "number", x, "y", "number", y, "colour", "number", colour )

	self.cursor_active = true
	self.cursor_x = x
	self.cursor_y = y
	self.cursor_colour = colour
	return self
end

function Sheet:resetCursorBlink()
	self.cursor_active = false
	return self
end

function Sheet:tostring()
	return "[Instance] " .. self.class:type() .. " " .. tostring( self.id )
end

function Sheet:onParentResized() end

function Sheet:update( dt )
	local c = {}
	local children = self.children

	self:updateAnimations( dt )

	if self.onUpdate then
		self:onUpdate( dt )
	end

	for i = 1, #children do
		c[i] = children[i]
	end

	for i = #c, 1, -1 do
		c[i]:update( dt )
	end
end

function Sheet:draw()
	if self.changed then

		local children = self.children
		local cx, cy, cc

		self:resetCursorBlink()

		if self.onPreDraw then
			self:onPreDraw()
		end

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( self.canvas, child.x, child.y )

			if child.cursor_active then
				cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
			end
		end

		if cx then
			self:setCursorBlink( cx, cy, cc )
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
			event:handle( self )
		end
	end
end
