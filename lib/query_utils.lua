
 -- @once

query_utils = {}

function query_utils.parse( query, pos )
	local mode = "ID"

	if query:sub( pos, pos ) == "." then
		mode = "tag"
		pos = pos + 1
	elseif query:sub( pos, pos ) == "#" then
		pos = pos + 1
	elseif not query:find( "^[%w_-]", pos ) then
		error( "TODO: fix this error", 0 )
	end

	local name = query:match( "^[%w_%-]+", pos )

	if not name then
		error( "TODO: fix this error", 0 )
	end

	return { type = mode, name = name }, pos + #name
end

function query_utils.compile_function( query )
	local name = query.name

	if query.type == "tag" then
		return function( node ) return node:has_tag( name ) end
	elseif query.type == "ID" then
		return function( node ) return node.id == name end
	else
		error( "TODO: fix this error", 0 )
	end
end

function query_utils.get_function( query )
	local query_parsed, position = query_utils.parse( query, 1 )

	if position <= #query then
		error( "TODO: fix this error", 0 ) -- random crap at end of query
	end

	return query_utils.compile_function( query_parsed )
end
