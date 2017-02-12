
class "QueryTracker" {
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
			local t = self.lifetimes[ID]

			for i = 1, #t do
				local l = t[i]
				if l[1] == "value" then
					l[2].values:unsubscribe( l[3], l[4] )
				elseif l[1] == "query" then
					l[2]:unsubscribe( l[3], l[4] )
				end
			end

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

				local callbacks = self.subscriptions[self.queries[i][3]] or {}

				for n = 1, #callbacks do
					callbacks[n]( "child-added", child )
				end
			else
				local callbacks = self.subscriptions[self.queries[i][3]]

				for n = 1, #callbacks do
					callbacks[n]( "child-changed", child )
				end
			end
		elseif remove then
			local t = self.queries[i][2]

			for n = 1, #t do
				if t[n] == child then
					local callbacks = self.subscriptions[self.queries[i][3]]

					table.remove( t, n )

					for n = 1, #callbacks do
						callbacks[n]( "child-removed", child )
					end

					break
				end
			end
		end
	end
end
