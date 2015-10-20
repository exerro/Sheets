
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPosition'
 -- @endif

 -- @print Including sheets.interfaces.IPosition

IPosition = {}

IPosition.x = 0
IPosition.y = 0
IPosition.width = 0
IPosition.height = 0

function IPosition:IPosition( x, y, width, height )
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function IPosition:setX( x )
	-- @if SHEETS_TYPE_CHECK
		if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	-- @endif
	if self.x ~= x then
		self.x = x
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function IPosition:setY( y )
	-- @if SHEETS_TYPE_CHECK
		if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	-- @endif
	if self.y ~= y then
		self.y = y
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function IPosition:setWidth( width )
	-- @if SHEETS_TYPE_CHECK
		if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end
	-- @endif
	if self.width ~= width then
		self.width = width
		for i = 1, #self.children do
			self.children[i]:onParentResized()
		end
		self.canvas:setWidth( width )
		self:setChanged( true )
	end
	return self
end

function IPosition:setHeight( height )
	-- @if SHEETS_TYPE_CHECK
		if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end
	-- @endif
	if self.height ~= height then
		self.height = height
		for i = 1, #self.children do
			self.children[i]:onParentResized()
		end
		self.canvas:setHeight( height )
		self:setChanged( true )
	end
	return self
end
