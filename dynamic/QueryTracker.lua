
 -- @include lib.lifetime

 -- @print including(dynamic.QueryTracker)

@class QueryTracker {
parent = nil;
	queries = {};
	lifetimes = {};
	subscriptions = {};
	ID = 0;
}

function QueryTracker:QueryTracker( parent )
	self.parent = parent
	self.queries = {}
	self.lifetimes = {}
	self.subscriptions = {}
end

function QueryTracker:track( query, nodes )
	local ID = self.ID

	self.queries[#self.queries + 1] = { query, nodes, ID }
	self.ID = ID + 1
	self.lifetimes[ID] = {}

	return ID
end

function QueryTracker:is_tracking( ID )
	for i = 1, #self.queries do
		if self.queries[i][3] == ID then
			return true
		end
	end

	return false
end

function QueryTracker:get_query( ID )
	for i = 1, #self.queries do
		if self.queries[i][3] == ID then
			return self.queries[i]
		end
	end
end

function QueryTracker:untrack( ID )
	for i = #self.queries, 1, -1 do
		if self.queries[i][3] == ID then
			lifetime.destroy( self.lifetimes[ID] )
			self.lifetimes[ID] = nil
			self.subscriptions[ID] = nil

			return table.remove( self.queries, i )
		end
	end
end

function QueryTracker:subscribe( ID, lifetime, callback )
	local t = self.subscriptions[ID] or {}

	lifetime[#lifetime + 1] = { "query", self, ID, callback }
	self.subscriptions[ID] = t
	t[#t + 1] = callback
end

function QueryTracker:unsubscribe( ID, callback )
	if self.subscriptions[ID] then
		for i = #self.subscriptions[ID], 1, -1 do
			if self.subscriptions[ID][i] == callback then
				if #self.subscriptions[ID] == 1 then
					self:untrack( ID )
				else
					table.remove( self.subscriptions[ID], i )
				end

				return callback
			end
		end
	end
end

function QueryTracker:update( mode, child )
	for i = 1, #self.queries do
		local add, remove = (mode == "child-added" or mode == "child-changed") and self.queries[i][1]( child ), mode == "child-removed"

		if mode == "child-changed" and not add then
			remove = true
		end

		if add then
			local nodes = self.queries[i][2]
			local collated = self.parent.collated_children
			local n = 1

			for i = 1, #collated do
				if collated[i] == child then
					break
				elseif collated[i] == nodes[n] then
					n = n + 1
				end
			end

			if nodes[n] ~= child then -- if it's not already in the query
				table.insert( nodes, n, child )
				self:invoke_child_change( self.queries[i][3], child, "child-added" )
			else
				self:invoke_child_change( self.queries[i][3], child, "child-changed" )
			end
		elseif remove then
			local t = self.queries[i][2]

			for n = 1, #t do
				if t[n] == child then
					table.remove( t, n )
					self:invoke_child_change( self.queries[i][3], child, "child-removed" )

					break
				end
			end
		end
	end
end

function QueryTracker:invoke_child_change( query_ID, child, mode )
	local callbacks = self.subscriptions[query_ID] or {}

	for i = 1, #callbacks do
		callbacks[i]( mode, child )
	end
end
