
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPositionContainer'
 -- @endif

 -- @print Including sheets.interfaces.IPositionContainer

IPositionContainer = {}

IPositionContainer.x = 0
IPositionContainer.y = 0
IPositionContainer.width = 0
IPositionContainer.height = 0

function IPositionContainer:IPositionContainer( x, y, width, height )
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function IPositionContainer:setX( x )
	-- @if SHEETS_TYPE_CHECK
		if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	-- @endif
	self.x = x
	if self.parent then self.parent:setChanged( true ) end
	return self
end

function IPositionContainer:setY( y )
	-- @if SHEETS_TYPE_CHECK
		if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	-- @endif
	self.y = y
	if self.parent then self.parent:setChanged( true ) end
	return self
end

function IPositionContainer:setWidth( width )
	-- @if SHEETS_TYPE_CHECK
		if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end
	-- @endif
	self.width = width
	for i = 1, #self.children do
		self.children[i]:onParentResized()
	end
	self:setChanged( true )
	return self
end

function IPositionContainer:setHeight( height )
	-- @if SHEETS_TYPE_CHECK
		if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end
	-- @endif
	self.height = height
	for i = 1, #self.children do
		self.children[i]:onParentResized()
	end
	self:setChanged( true )
	return self
end
