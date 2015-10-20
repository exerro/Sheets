
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Sheet'
 -- @endif

 -- @print Including sheets.Sheet

local function orderChildren( children )
	local t = {}
	for i = 1, #children do
		local n = 1
		while t[n] and t[n].z <= children[i].z do
			n = n + 1
		end
		table.insert( t, n, children[i] )
	end
	return t
end

class "Sheet" implements (IChildContainer) implements (IPosition) implements (IAnimation) implements (IHasParent) implements (IPositionAnimator)
{
	id = "ID";
	z = 0;
	parent = nil;

	changed = true;

	canvas = nil;
	theme = nil;

	handlesKeyboard = true;
	handlesText = true;
}

function Sheet:Sheet( x, y, width, height )
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
	self.theme = default_theme
end

function Sheet:tostring()
	return "[Instance] Sheet " .. tostring( self.id )
end

function Sheet:setID( id )
	self.id = tostring( id )
	return self
end

function IChildContainer:setTheme( theme, children )
	theme = theme or Theme()
	-- @if SHEETS_TYPE_CHECK
		if not class.typeOf( theme, Theme ) then return error( "expected Theme theme, got " .. type( theme ) ) end
	-- @endif
	self.theme = theme
	if children then
		for i = 1, #self.children do
			self.children[i]:setTheme( theme, true )
		end
	end
	self:setChanged( true )
	return self
end

function Sheet:setZ( z )
	-- @if SHEETS_TYPE_CHECK
		if type( z ) ~= "number" then return error( "expected number z, got " .. class.type( z ) ) end
	-- @endif
	self.z = z
	if self.parent then self.parent:setChanged( true ) end
	return self
end

function Sheet:setChanged( state )
	self.changed = state ~= false
	if state ~= false and self.parent and not self.parent.changed then
		self.parent:setChanged( true )
	end
	return self
end

function Sheet:onPreDraw() end
function Sheet:onPostDraw() end
function Sheet:onUpdate( dt ) end
function Sheet:onMouseEvent( event ) end
function Sheet:onKeyboardEvent( event ) end
function Sheet:onTextEvent( event ) end
function Sheet:onParentResized() end

function Sheet:draw()
	if self.changed then
		self:onPreDraw()

		local children = orderChildren( self.children )

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( self.canvas, child.x, child.y )
		end

		self:onPostDraw()
		self.changed = false
	end
end

function Sheet:update( dt )
	 -- @if SHEETS_TYPE_CHECK
		if type( dt ) ~= "number" then return error( "expected number dt, got " .. class.type( dt ) ) end
	 -- @endif
	self:onUpdate( dt )
	self:updateAnimations( dt )

	local c = {}
	for i = 1, #self.children do
		c[i] = self.children[i]
	end

	for i = #c, 1, -1 do
		c[i]:update( dt )
	end
end

function Sheet:handle( event )
	local c = orderChildren( self.children )

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
	elseif event:typeOf( KeyboardEvent ) and self.handlesKeyboard then
		self:onKeyboardEvent( event )
	elseif event:typeOf( TextEvent ) and self.handlesText then
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
