
 -- @once
 -- @print Including sheets.interfaces.IChildContainer

interface "IChildContainer" {
	children = {};
}

function IChildContainer:IChildContainer()
	self.children = {}

	self.meta.__add = self.add_child

	function self.meta:__concat( child )
		self:add_child( child )
		return self
	end
end

function IChildContainer:add_child( child )
	parameters.check( 1, "child", Sheet, child )

	local children = self.children

	if child.parent then
		child.parent:remove_child( child )
	end

	child.parent = self
	self:set_changed()

	for i = 1, #children do
		if children[i].z > child.z then
			table.insert( children, i, child )
			return child
		end
	end

	children[#children + 1] = child
	return child
end

function IChildContainer:remove_child( child )
	for i = 1, #self.children do
		if self.children[i] == child then
			child.parent = nil
			self:set_changed()
			return table.remove( self.children, i )
		end
	end
end

function IChildContainer:get_children()
	local c = {}
	local children = self.children

	for i = 1, #children do
		c[i] = children[i]
	end

	return c
end

function IChildContainer:get_child_by_id( id )
	parameters.check( 1, "id", "string", id )

	for i = #self.children, 1, -1 do
		local c = self.children[i]:get_child_by_id( id )
		if c then
			return c
		elseif self.children[i].id == id then
			return self.children[i]
		end
	end
end

function IChildContainer:get_children_by_id( id )
	parameters.check( 1, "id", "string", id )

	local t = {}
	for i = #self.children, 1, -1 do
		local subt = self.children[i]:get_children_by_id( id )
		for i = 1, #subt do
			t[#t + 1] = subt[i]
		end
		if self.children[i].id == id then
			t[#t + 1] = self.children[i]
		end
	end
	return t
end

function IChildContainer:get_children_at( x, y )
	parameters.check( 2, "x", "number", x, "y", "number", y )

	local c = self:get_children()
	local elements = {}

	for i = #c, 1, -1 do
		c[i]:handle( MouseEvent( EVENT_MOUSE_PING, x - c[i].x, y - c[i].y, elements, true ) )
	end

	return elements
end

function IChildContainer:is_child_visible( child )
	parameters.check( 1, "child", Sheet, child )

	return child.x + child.width > 0 and child.y + child.height > 0 and child.x < self.width and child.y < self.height
end

function IChildContainer:reposition_childz_index( child )
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

			self:set_changed()
			break
		end
	end
end
