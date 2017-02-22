
 -- @print including(interfaces.ICollatedChildren)

@interface ICollatedChildren {
	collated_children = {}
}

function ICollatedChildren:ICollatedChildren()
	self.collated_children = {}

	function self:ICollatedChildren() end
end

function ICollatedChildren:update_collated( mode, child, data )
	local collated = self.collated_children

	if mode == "child-added" then
		if data == self then
			if child:implements( ICollatedChildren ) then
				for i = 1, #child.collated_children do
					collated[#collated + 1] = child.collated_children[i]
				end
			end

			collated[#collated + 1] = child
		else
			for i = #collated, 1, -1 do
				if collated[i] == data then
					if child:implements( ICollatedChildren ) then
						i = i - 1 -- so that i + n starts with just i

						for n = 1, #child.collated_children do
							table.insert( collated, i + n, child.collated_children[n] )
						end

						table.insert( collated, i + #child.collated_children + 1, child )
					else
						table.insert( collated, i, child )
					end
				end
			end
		end

		if self.parent then
			self.parent:update_collated( "child-added", child, data )
		end
	elseif mode == "child-removed" then
		local open, close = child:implements( ICollatedChildren ) and child.collated_children[1] or child, child
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

	if self.query_tracker then
		self.query_tracker:update( mode, child )
	end
end
