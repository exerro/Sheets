
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Sheet'
 -- @endif

 -- @print Including sheets.Sheet

class "Sheet"
{
	id = "default";

	x = 0;
	y = 0;
	z = 0;

	ox = 0;
	oy = 0;

	width = 0;
	height = 0;

	parent = nil;
	children = {};
	animations = {};

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
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	self.children = {}
	self.animations = {}

	self.canvas = DrawingCanvas( width, height )
	self.theme = Theme()

	self.meta.__add = self.addChild
end

function Sheet:tostring()
	return "[Instance] Sheet " .. self.id
end

function Sheet:setID( id )
	-- @if SHEETS_TYPE_CHECK
		if type( id ) ~= "string" then return error( "expected string id, got " .. class.type( id ) ) end
	-- @endif
	self.id = id
	return self
end

function Sheet:setX( x )
	-- @if SHEETS_TYPE_CHECK
		if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	-- @endif
	if self.parent then self.parent:setChanged( true ) end
	self.x = x
	return self
end

function Sheet:setY( y )
	-- @if SHEETS_TYPE_CHECK
		if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	-- @endif
	if self.parent then self.parent:setChanged( true ) end
	self.y = y
	return self
end

function Sheet:setWidth( width )
	-- @if SHEETS_TYPE_CHECK
		if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end
	-- @endif
	self:setChanged( true )
	self.width = width
	for i = 1, #self.children do
		self.children[i]:onParentResized()
	end
	return self
end

function Sheet:setHeight( height )
	-- @if SHEETS_TYPE_CHECK
		if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end
	-- @endif
	self:setChanged( true )
	self.height = height
	for i = 1, #self.children do
		self.children[i]:onParentResized()
	end
	return self
end

function Sheet:setChanged( state )
	self.changed = state
	if state and self.parent then
		self.parent:setChanged( true )
	end
	return self
end

function Sheet:setParent( parent )
	-- @if SHEETS_TYPE_CHECK
		if parent ~= nil and not class.typeOf( parent, Sheet ) then return error( "expected Sheet parent, got " .. type( parent ) ) end
	-- @endif
	self:remove()
	if parent then
		parent:addChild( self )
	end
	return self
end

function Sheet:getElementById( id )
	for i = #self.children, 1, -1 do
		local c = self.children[i]:getElementById( id )
		if c then
			return c
		elseif self.children[i].id == id then
			return self.children[i]
		end
	end
end

function Sheet:getElementsById( id )
	local t = {}
	for i = #children, 1, -1 do
		local subt = children[i]:getElementById( id )
		for i = 1, #subt do
			t[#t + 1] = subt[i]
		end
		if children[i].id == id then
			t[#t + 1] = children[i]
		end
	end
	return t
end

function Sheet:addChild( child )
	-- @if SHEETS_TYPE_CHECK
		if not class.typeOf( child, Sheet ) then return error( "expected Sheet child, got " .. class.type( child ) ) end
	-- @endif
	if child.parent then
		child:remove()
	end

	self:setChanged( true )
	child.parent = self
	self.children[#self.children + 1] = child
	return child
end

function Sheet:removeChild( child )
	for i = #self.children, 1, -1 do
		if self.children[i] == child then
			self:setChanged( true )
			child.parent = nil

			return table.remove( self.children, i )
		end
	end
end

function Sheet:remove()
	if self.parent then
		return self.parent:removeChild( self )
	end
end

function Sheet:onDraw() end
function Sheet:onUpdate( dt ) end
function Sheet:onMouseEvent( event ) end
function Sheet:onKeyboardEvent( event ) end
function Sheet:onTextEvent( event ) end
function Sheet:onParentResized() end

function Sheet:draw()
	if self.changed then
		local canvas = self.canvas
		local ox, oy = self.ox, self.oy

		-- canvas:clear()
		self:onDraw()

		for i = 1, #self.children do -- needs to do z ordering
			local child = self.children[i]
			child:draw()
			child.canvas:drawTo( canvas, child.x + ox, child.y + oy )
		end
	end
end

function Sheet:update( dt )
	self:onUpdate( dt )
	local c = {}
	for i = 1, #self.children do
		c[i] = self.children[i]
	end
	for i = #c, 1, -1 do
		c[i]:update( dt )
	end
end

function Sheet:handleInput( event )
	local c = {}
	for i = 1, #self.children do
		c[i] = self.children[i]
	end
	if event:typeOf( MouseEvent ) then
		local within = event.within and event:isWithinArea( 0, 0, self.width, self.height )
		local ox, oy = self.ox, self.oy
		for i = #c, 1, -1 do
			c[i]:handle( event:clone( c[i].x + ox, c[i].y + oy, within ) )
		end
	else
		for i = #c, 1, -1 do
			c[i]:handle( event )
		end
	end

	if event:typeOf( MouseEvent ) and self.handlesMouse then
		if event.name == EVENT_MOUSE_PING and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then
			event.button[#event.button + 1] = self
		end
		self:onMouseEvent( event )
	elseif event:typeOf( KeyboardEvent ) and self.handlesKeyboard then
		self:onKeyboardEvent( event )
	elseif event:typeOf( TextEvent ) and self.handlesText then
		self:onTextEvent( event )
	end
end

function Sheet:handleTimerEvent( timer )

end

function Sheet:handleParentResize()

end
