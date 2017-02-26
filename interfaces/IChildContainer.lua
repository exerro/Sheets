
 -- @print including(interfaces.IChildContainer)

@private
@interface IChildContainer implements ICollatedChildren, IQueryable {
	children = {};
	application = nil;
}

function IChildContainer:IChildContainer()
	self.children = {}

	self.meta.__add = self.add_child

	function self.meta:__concat( child )
		self:add_child( child )
		return self
	end

	function self:IChildContainer() end

	self:ICollatedChildren()
	self:IQueryable()
end

function IChildContainer:child_value_changed( child )
	self.query_tracker:update( "child-changed", child )

	if self.parent then
		return self.parent:child_value_changed( child )
	end
end

function IChildContainer:add_child( child )
	parameters.check( 1, "child", Sheet, child )

	local children = self.children
	local collated = self.collated_children

	if child.parent then
		child.parent:remove_child( child, true )
	end

	local index = #children + 1

	for i = 1, #children do
		if children[i].z > child.z then
			index = i
			break
		end
	end

	local c, l = children[index], index <= #children

	table.insert( children, index, child )
	self:update_collated( "child-added", child, l and (c:implements( ICollatedChildren ) and c.collated_children[1] or c) or self )
	self:set_changed()

	if child:implements( ICollatedChildren ) then
		for i = 1, #child.collated_children do
			child.collated_children[i].application = self.application
			child.collated_children[i].values:trigger "application"
		end
	end

	child.parent = self
	child.application = self.application
	child.values:trigger "parent"
	child.values:trigger "application"
	child.values:child_inserted()

	return child
end

function IChildContainer:remove_child( child, reinsert )
	for i = 1, #self.children do
		if self.children[i] == child then
			child.parent = nil
			child.application = nil

			table.remove( self.children, i )
			self:set_changed()
			self:update_collated( "child-removed", child )

			if child:implements( ICollatedChildren ) then
				for i = 1, #child.collated_children do
					child.collated_children[i].application = nil
					child.collated_children[i].values:trigger "application"
				end
			end

			child.values:trigger "parent"
			child.values:trigger "application"

			if not reinsert then
				child.values:child_removed()
			end

			return child
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
			local moved = false

			while children[i-1] and children[i-1].z > child.z do
				children[i-1], children[i] = child, children[i-1]
				moved = true
				i = i - 1
			end

			while children[i+1] and children[i+1].z < child.z do
				children[i+1], children[i] = child, children[i+1]
				moved = true
				i = i + 1
			end

			if moved then
				self:update_collated( "child-removed", child )
				self:update_collated( "child-added", child, i + 1 > #children and self or children[i + 1]:implements( ICollatedChildren ) and children[i + 1].collated_children[1] or children[i + 1] )
				self:set_changed()
			end

			break
		end
	end
end
