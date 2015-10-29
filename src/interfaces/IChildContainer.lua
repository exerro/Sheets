
IChildContainer = {
	children = {}
}

function IChildContainer:IChildContainer()
	self.children = {}

	self.meta.__add = self.addChild

	function self.meta:__concat( child )
		self:addChild( child )
		return self
	end
end

function IChildContainer:addChild( child )
	if not class.typeOf( child, Sheet ) then return error( "expected Sheet child, got " .. class.type( child ) ) end

	local children = self.children

	if child.parent then
		child.parent:removeChild( child )
	end

	child.parent = self
	self:setChanged()

	for i = 1, #children do
		if children[i].z > child.z then
			table.insert( children, i, child )
			return child
		end
	end

	children[#children + 1] = child
	return child
end

function IChildContainer:removeChild( child )
	for i = 1, #self.children do
		if self.children[i] == child then
			child.parent = nil
			self:setChanged()
			return table.remove( self.children, i )
		end
	end
end

function IChildContainer:repositionChildZIndex( child )
	local children = self.children

	for i = 1, #children do
		if children[i] == child then
			while children[i-1] and children[i-1].z > child.z do
				children[i-1], children[i] = child, children[i-1]
				i = i - 1
			end
			while children[i+1] and children[i+1].z < child.z do
				children[i+1], children[i] = child, children[i+1]
				i = i + 1
			end
			
			self:setChanged()
			break
		end
	end
end

function IChildContainer:getChildById( id )
	if type( id ) ~= "string" then return error( "expected string id, got " .. class.type( id ) ) end

	for i = #self.children, 1, -1 do
		local c = self.children[i]:getChildById( id )
		if c then
			return c
		elseif self.children[i].id == id then
			return self.children[i]
		end
	end
end

function IChildContainer:getChildrenById( id )
	if type( id ) ~= "string" then return error( "expected string id, got " .. class.type( id ) ) end

	local t = {}
	for i = #self.children, 1, -1 do
		local subt = self.children[i]:getChildrenById( id )
		for i = 1, #subt do
			t[#t + 1] = subt[i]
		end
		if self.children[i].id == id then
			t[#t + 1] = self.children[i]
		end
	end
	return t
end

function IChildContainer:getChildrenAt( x, y )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end

	local c = {}
	local children = self.children
	for i = 1, #children do
		c[i] = children[i]
	end

	local elements = {}

	for i = #c, 1, -1 do
		c[i]:handle( MouseEvent( EVENT_MOUSE_PING, x - c[i].x, y - c[i].y, elements, true ) )
	end

	return elements
end

function IChildContainer:isChildVisible( child )
	if not class.typeOf( child, Sheet ) then return error( "expected Sheet child, got " .. class.type( child ) ) end
	return child.x + child.width > 0 and child.y + child.height > 0 and child.x < self.width and child.y < self.height
end

function IChildContainer:update( dt )
	if type( dt ) ~= "number" then return error( "expected number dt, got " .. class.type( dt ) ) end

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
