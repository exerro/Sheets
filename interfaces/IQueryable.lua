
 -- @once
 -- @print Including sheets.interfaces.IQueryable

local function query_raw( self, query, track, parsed )
	if not parsed then
		parameters.check( 1, "query", "string", query )

		local parser = QueryParser( Stream( query ) )
		
		query = parser:parse_query()
	end

	local query_f = Codegen.node_query( query )
	local nodes = self.collated_children
	local matches = {}

	for i = 1, #nodes do
		if query_f( nodes[i] ) then
			matches[#matches + 1] = nodes[i]
		end
	end

	if track then
		return matches, self.query_tracker:track( query_f, matches )
	else
		return matches
	end
end

interface "IQueryable" implements "ICollatedChildren" {
	query_tracker = nil;
}

function IQueryable:IQueryable()
	self.query_tracker = QueryTracker( self )
end

function IQueryable:query( query )
	return query_raw( self, query, false, false )
end

function IQueryable:query_tracked( query )
	return query_raw( self, query, true, false )
end

function IQueryable:preparsed_query( query )
	return query_raw( self, query, false, true )
end

function IQueryable:preparsed_query_tracked( query )
	return query_raw( self, query, true, true )
end
