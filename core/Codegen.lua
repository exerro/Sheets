
local function node_query_internal( query )
	if query.type == QUERY_ID then
		return ("n.id=='%s'"):format( query.value )
	elseif query.type == QUERY_TAG then
		return ("n:has_tag'%s'"):format( query.value )
	elseif query.type == QUERY_ALL then
		return "true"
	elseif query.type == QUERY_CLASS then
		-- TODO: check if type_of() accepts a string
		return ("n:type_of'%s'"):format( query.value )
	elseif query.type == QUERY_NEGATE then
		local i = node_query_internal( query.value )
		return i == "true" and "false" or i == "false" and "true" or "not " .. i
	elseif query.type == QUERY_ATTRIBUTES then
		-- TODO!
		error "NYI"
	elseif query.type == QUERY_OPERATOR then
		local lvalue = node_query_internal( query.lvalue )
		local rvalue = node_query_internal( query.rvalue )

		if query.operator == "&" then
			if lvalue == "true" then return rvalue end
			if rvalue == "true" then return lvalue end
			if lvalue == "false" then return lvalue end
			if rvalue == "false" then return rvalue end

			return lvalue .. " and " .. rvalue
		elseif query.operator == "|" then
			if lvalue == "true" then return lvalue end
			if rvalue == "true" then return rvalue end
			if lvalue == "false" then return rvalue end
			if rvalue == "false" then return lvalue end

			return lvalue .. " or " .. rvalue
		end
	end
end

class "Codegen" {}

function Codegen.node_query( parsed_query )
	return load( "local n=...return " .. node_query_internal( parsed_query ), "query" )
end
