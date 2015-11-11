
interface "IChildContainer" {
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
	functionParameters.check( 1, "child", Sheet, child )

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

function IChildContainer:getChildById( id )
	functionParameters.check( 1, "id", "string", id )

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
	functionParameters.check( 1, "id", "string", id )

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
	functionParameters.check( 2, "x", "number", x, "y", "number", y )

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
	functionParameters.check( 1, "child", Sheet, child )

	return child.x + child.width > 0 and child.y + child.height > 0 and child.x < self.width and child.y < self.height
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
