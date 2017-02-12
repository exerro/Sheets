
 -- @once
 -- @print Including sheets.interfaces.IQueryable

local setf, addtag, remtag, query_raw

interface "IQueryable" implements "ICollatedChildren" {
	query_tracker = nil;
}

function IQueryable:IQueryable()
	self.query_tracker = QueryTracker( self )
end

function IQueryable:iquery( query )
	local results = query_raw( self, query, nil, false, false )
	local i = 0

	return function()
		i = i + 1
		return results[i], i
	end
end

function IQueryable:query( query )
	return query_raw( self, query, nil, false, false )
end

function IQueryable:query_tracked( query )
	return query_raw( self, query, nil, true, false )
end

function IQueryable:preparsed_query( query, lifetime )
	return query_raw( self, query, lifetime, false, true )
end

function IQueryable:preparsed_query_tracked( query, lifetime )
	return query_raw( self, query, lifetime, true, true )
end

function setf( self, properties )
	local prop_setters = {}

	for k, v in pairs( properties ) do
		prop_setters[#prop_setters + 1] = { k, "set_" .. k, v }
	end

	for i = 1, #self do
		local vals = self[i].values
		for n = 1, #prop_setters do
			if vals:has( prop_setters[n][1] ) then
				self[i][prop_setters[n][2]]( self[i], prop_setters[n][3] )
			end
		end
	end
end

function addtag( self, tag )
	for i = 1, #self do
		self[i]:add_tag( tag )
	end
end

function remtag( self, tag )
	for i = 1, #self do
		self[i]:remove_tag( tag )
	end
end

function query_raw( self, query, lifetime, track, parsed )
	if not parsed then
		lifetime = {}
		parameters.check( 1, "query", "string", query )
		query = DynamicValueParser( Stream( query ) ):parse_query()
	end

	local query_f, init_f = Codegen.node_query( query )
	local nodes = self.collated_children
	local matches = { set = setf, add_tag = addtag, remove_tag = remtag }

	init_f()

	for i = 1, #nodes do
		if query_f( nodes[i] ) then
			matches[#matches + 1] = nodes[i]
		end
	end

	if track then
		local ID = self.query_tracker:track( query_f, matches )

		self.query_tracker.lifetimes[ID] = lifetime

		return matches, ID
	else
		-- TODO: destroy lifetime
		return matches
	end
end
