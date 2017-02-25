
 -- @include codegen.dynamic_value

 -- @print including(dynamic.codegen.node_query)
 -- @localise node_query_codegen

local function node_query_internal( query, name, tracked )
	if query.type == QUERY_ID then
		return ("%s.id=='%s'"):format( name, query.value )
	elseif query.type == QUERY_TAG then
		return ("%s:has_tag'%s'"):format( name, query.value )
	elseif query.type == QUERY_ANY then
		return "true"
	elseif query.type == QUERY_CLASS then
		return ("%s:type():lower()=='%s'"):format( name, query.value:lower() )
	elseif query.type == QUERY_NEGATE then
		local i = node_query_internal( query.value, name, tracked )
		return i == "true" and "false" or i == "false" and "true" or "not (" .. i .. ")"
	elseif query.type == QUERY_ATTRIBUTES then
		local t = {}
		local idx = #tracked + 1

		for i = 1, #query.attributes do
			local attr = query.attributes[i]
			local op = attr.comparison

			if op == "=" then
				op = "=="
			end

			tracked[idx] = { value = attr.value }
			t[i] = "v" .. idx .. " and " .. name .. "." .. attr.name .. " " .. op .. " v" .. idx
			idx = idx + 1
		end

		return table.concat( t, " and " )
	elseif query.type == QUERY_OPERATOR then
		if query.operator == "&" then
			local lvalue = node_query_internal( query.lvalue, name, tracked )
			local rvalue = node_query_internal( query.rvalue, name, tracked )

			if lvalue == "true" then return rvalue end
			if rvalue == "true" then return lvalue end
			if lvalue == "false" then return lvalue end
			if rvalue == "false" then return rvalue end

			return lvalue .. " and " .. rvalue
		elseif query.operator == "|" then
			local lvalue = node_query_internal( query.lvalue, name, tracked )
			local rvalue = node_query_internal( query.rvalue, name, tracked )

			if lvalue == "true" then return lvalue end
			if rvalue == "true" then return rvalue end
			if lvalue == "false" then return rvalue end
			if rvalue == "false" then return lvalue end

			return "(" .. lvalue .. " or " .. rvalue .. ")"
		elseif query.operator == ">" then
			local lvalue = node_query_internal( query.lvalue, name .. ".parent", tracked )
			local rvalue = node_query_internal( query.rvalue, name, tracked )

			if lvalue == "true" then return name .. ".parent and " .. rvalue end
			if rvalue == "true" then return name .. ".parent and " .. lvalue end
			if lvalue == "false" then return lvalue end
			if rvalue == "false" then return rvalue end

			return rvalue .. " and " .. name .. ".parent and " .. lvalue
		end
	end
end

function node_query_codegen( parsed_query, lifetime, updater )
	local names = {}
	local named_values = {}
	local val_names = {}
	local init_localised = {}
	local initialise_code = {}
	local tracked = {}
	local query_str = node_query_internal( parsed_query, "n", tracked )
	local tl = #tracked

	for i = 1, tl do
		names[i] = "n" .. i
		named_values[i] = tracked[i].value
		init_localised[i] = "f" .. i
		init_localised[tl + i] = "i" .. i
		val_names[i] = "v" .. i
		initialise_code[i] = "f" .. i .. ", i" .. i .. " = dynamic_value_codegen( n" .. i .. ", lifetime, env, n, function()\n"
		initialise_code[i] = "f" .. i .. ", i" .. i .. " = dynamic_value_codegen( n" .. i .. ", lifetime, env, n, function()\n"
		                  .. "\tv" .. i .. " = f" .. i .. "()\n"
						  .. "\treturn updater()\n"
						  .. "end )"
	end

	for i = 1, tl do
		initialise_code[i + tl] = "i" .. i .. "()"
	end

	for i = 1, tl do
		initialise_code[i + tl + tl] = "v" .. i .. " = f" .. i .. "()"
	end

	local code = "local lifetime, updater" .. (#names == 0 and "" or ", " .. table.concat( names, ", " )) .. " = ...\n"
	          .. (#val_names == 0 and "" or "local " .. table.concat( val_names, ", " ) .. "\n")
	          .. "return function( n )\n"
			  .. "\treturn " .. query_str
			  .. "\nend, function( n )\n"
		      .. "\tlocal env = {}\n"
			  .. (#init_localised == 0 and "" or "\tlocal " .. table.concat( init_localised, ", " ) .. "\n")
			  .. table.concat( initialise_code, "\n" )
			  .. "\nend"

	local env = setmetatable( { dynamic_value_codegen = dynamic_value_codegen }, { __index = _ENV or getfenv() } )
	local f, err = assert( (load or loadstring)( code, "query", nil, env ) )

	if setfenv then
		setfenv( f, env )
	end

	local getter, initialiser = f( lifetime, updater, unpack( named_values ) )
	return getter, initialiser
end
