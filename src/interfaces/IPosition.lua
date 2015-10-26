
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPosition'
 -- @endif

 -- @print Including sheets.interfaces.IPosition

IPosition = {
	x = 0;
	y = 0;
	z = 0;

	width = 0;
	height = 0;
}

function IPosition:IPosition( x, y, width, height )
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function IPosition:setX( x )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	
	if self.x ~= x then
		self.x = x
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function IPosition:setY( y )
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	
	if self.y ~= y then
		self.y = y
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function IPosition:setZ( z )
	if type( z ) ~= "number" then return error( "expected number z, got " .. class.type( z ) ) end

	if self.z ~= z then
		self.z = z
		if self.parent then self.parent:repositionChildZIndex( self ) end
	end
	return self
end

function IPosition:setWidth( width )
	if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end

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
	if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end

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
