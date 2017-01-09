
 -- @once
 -- @print Including sheets.interfaces.IChildContainer

interface "IChildContainer" {
	children = {};
	collated_children = {};
}

function IChildContainer:IChildContainer()
	self.children = {}
	self.collated_children = {}

	self.meta.__add = self.add_child

	function self.meta:__concat( child )
		self:add_child( child )
		return self
	end
end

function IChildContainer:update_collated( mode, child, data )
	local collated = self.collated_children

	if mode == "child-added" then
		if data == self then
			for i = 1, #child.collated_children do
				collated[#collated + 1] = child.collated_children[i]
			end

			collated[#collated + 1] = child
		else
			for i = #collated, 1, -1 do
				if collated[i] == data then
					i = i - 1 -- so that i + n starts with just i

					for n = 1, #child.collated_children do
						table.insert( collated, i + n, child.collated_children[n] )
					end

					table.insert( collated, i + #child.collated_children + 1, child )
				end
			end
		end

		if self.parent then
			self.parent:update_collated( "child-added", child, data )
		end
	elseif mode == "child-removed" then
		local open, close = child.collated_children[1] or child, child
		local removing = false

		for i = #collated, 1, -1 do
			if collated[i] == close then removing = true end
			local brk = collated[i] == open
			if removing then table.remove( collated, i ) end
			if brk then break end
		end

		if self.parent then
			self.parent:update_collated( "child-removed", child )
		end
	end
end

function IChildContainer:add_child( child )
	parameters.check( 1, "child", Sheet, child )

	local children = self.children
	local collated = self.collated_children

	if child.parent then
		child.parent:remove_child( child )
	end

	child.parent = self
	self:set_changed()

	local index = #children + 1

	for i = 1, #children do
		if children[i].z > child.z then
			index = i
			break
		end
	end

	self:update_collated( "child-added", child, index <= #children and (children[index].collated_children[1] or children[index]) or self )
	table.insert( children, index, child )

	return child
end

function IChildContainer:remove_child( child )
	for i = 1, #self.children do
		if self.children[i] == child then
			child.parent = nil
			self:set_changed()
			self:update_collated( "child-removed", child )

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

function IChildContainer:reposition_child_z_index( child )
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

			self:update_collated( "child-removed", child )
			self:update_collated( "child-added", child, i + 1 > #children and self or children[i + 1].collated_children[1] or children[i + 1] )

			self:set_changed()
			break
		end
	end
end
