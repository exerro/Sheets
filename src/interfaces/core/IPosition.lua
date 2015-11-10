
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
	functionParameters.check( 1, "x", "number", x )
	
	if self.x ~= x then
		self.x = x
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function IPosition:setY( y )
	functionParameters.check( 1, "y", "number", y )
	
	if self.y ~= y then
		self.y = y
		if self.parent then self.parent:setChanged( true ) end
	end
	return self
end

function IPosition:setZ( z )
	functionParameters.check( 1, "z", "number", z )

	if self.z ~= z then
		self.z = z
		if self.parent then self.parent:repositionChildZIndex( self ) end
	end
	return self
end

function IPosition:setWidth( width )
	functionParameters.check( 1, "width", "number", width )

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
	functionParameters.check( 1, "height", "number", height )

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
