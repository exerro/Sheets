
 -- @once
 -- @print Including sheets.interfaces.IChildContainer

interface "IChildContainer" implements "ICollatedChildren" {
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

function IChildContainer:child_value_changed( child )
	if self.query_tracker then
		self.query_tracker:update( "child-changed", child )
	end

	if self.parent then
		return self.parent:child_value_changed( child )
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

	child.root_application = self.root_application

	for i = 1, #child.collated_children do
		child.collated_children[i].root_application = self.root_application
	end

	return child
end

function IChildContainer:remove_child( child )
	for i = 1, #self.children do
		if self.children[i] == child then
			child.parent = nil
			self:set_changed()
			self:update_collated( "child-removed", child )

			child.root_application = nil

			for i = 1, #child.collated_children do
				child.collated_children[i].root_application = nil
			end

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
