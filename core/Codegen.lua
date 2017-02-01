
local cache = {}

local GENERIC_SETTER = [[return function( self, value )
	self.values:respawn %q
	self[%q] = value

	if type( value ) ~= "string" then
		-- do type check
		self[%q] = value

		%s

		self.values:trigger %q

		return self
	end

	%s

	local parser = DynamicValueParser( Stream( value ) )

	parser:set_context( "enable_queries", true )

	%s

	local value_parsed = parser:parse_expression()

	%s

	local lifetime = self.values.lifetimes[%q]
	local setter_f, queries

	local function update()
		self[%q] = setter_f( self )

		%s

		return self.values:trigger %q
	end

	if not parser.stream:is_EOF() then
		error "TODO: fix this error"
	end

	setter_f, queries = Codegen.dynamic_value( value_parsed, lifetime, parser.environment, self, update )

	for i = 1, #queries do
		queries[i].tracker:subscribe( queries[i].ID, lifetime, function()
			setter_f( nil, i, queries[i].result[1] )
			update()
		end )
	end

	if queries.parent then
		if queries.parent.value then
			queries.parent.child.values:subscribe( "child", lifetime, function()
				setter_f( nil, "parent", queries.parent.child.parent )
				update()
			end )
		end
	end

	update()

	return self
end]]

local GENERIC_GETTER_FUNCTION = [[
local lifetime, updater, default, properties, nodes, %s = ...
return function( self, i, value )
	if self then
		return %s or default
	else
		if properties[i] then
			if nodes[i] then
				nodes[i].values:unsubscribe( properties[i], updater )
			end
			if value then
				value.values:subscribe( properties[i], lifetime, updater )
			end
		end
		nodes[i] = value
	end
end]]

local function node_query_internal( query, name )
	if query.type == QUERY_ID then
		return ("%s.id=='%s'"):format( name, query.value )
	elseif query.type == QUERY_TAG then
		return ("%s:has_tag'%s'"):format( name, query.value )
	elseif query.type == QUERY_ANY then
		return "true"
	elseif query.type == QUERY_CLASS then
		return ("%s:type():lower()=='%s'"):format( name, query.value:lower() )
	elseif query.type == QUERY_NEGATE then
		local i = node_query_internal( query.value, name )
		return i == "true" and "false" or i == "false" and "true" or "not (" .. i .. ")"
	elseif query.type == QUERY_ATTRIBUTES then
		-- TODO: implement this
		error "NYI"
	elseif query.type == QUERY_OPERATOR then
		if query.operator == "&" then
			local lvalue = node_query_internal( query.lvalue, name )
			local rvalue = node_query_internal( query.rvalue, name )

			if lvalue == "true" then return rvalue end
			if rvalue == "true" then return lvalue end
			if lvalue == "false" then return lvalue end
			if rvalue == "false" then return rvalue end

			return lvalue .. " and " .. rvalue
		elseif query.operator == "|" then
			local lvalue = node_query_internal( query.lvalue, name )
			local rvalue = node_query_internal( query.rvalue, name )

			if lvalue == "true" then return lvalue end
			if rvalue == "true" then return rvalue end
			if lvalue == "false" then return rvalue end
			if rvalue == "false" then return lvalue end

			return "(" .. lvalue .. " or " .. rvalue .. ")"
		elseif query.operator == ">" then
			local lvalue = node_query_internal( query.lvalue, name .. ".parent" )
			local rvalue = node_query_internal( query.rvalue, name )

			if lvalue == "true" then return name .. ".parent and " .. rvalue end
			if rvalue == "true" then return name .. ".parent and " .. lvalue end
			if lvalue == "false" then return lvalue end
			if rvalue == "false" then return rvalue end

			return rvalue .. " and " .. name .. ".parent and " .. lvalue
		end
	end
end

local function dynamic_value_query( query, index, lifetime, env, obj, queries, names, updater )
	local source
	if query.source.type == DVALUE_APPLICATION then
		source = obj.root_application
	else
		error "TODO: fix this error"
	end

	local els, ID

	if query.type == DVALUE_DQUERY then
		els, ID = source:preparsed_query_tracked( query.query )
		queries[#queries + 1] = { tracker = source.query_tracker, ID = ID, result = els, index = index }
	else
		els = source:preparsed_query( query.query )
	end

	local el = els[1] or error "TODO: fix this area"

	if index then
		el.values:subscribe( index, lifetime, updater )
	end

	if query.type == DVALUE_QUERY then
		names[#names + 1] = el
		return "n" .. #names .. (index and "." .. index or "")
	else
		return "nodes[" .. #queries .. "]" .. (index and "." .. index or "")
	end
end

local function dynamic_value_internal( value, lifetime, env, obj, queries, names, updater )
	if value.type == DVALUE_INTEGER
	or value.type == DVALUE_FLOAT
	or value.type == DVALUE_BOOLEAN then
		return value.value

	elseif value.type == DVALUE_STRING then
		return ("%q"):format( value.value )

	elseif value.type == DVALUE_SELF then
		return "self"

	elseif value.type == DVALUE_PARENT then
		return "self.parent"

	elseif value.type == DVALUE_APPLICATION then
		return "self.root_application"

	elseif value.type == DVALUE_IDENTIFIER then
		-- names[#names + 1] = env[value.value]
		-- return "n" .. #names

		error "NYI"

	elseif value.type == DVALUE_PERCENTAGE then

	elseif value.type == DVALUE_UNEXPR then
		return value.operator .. " "
		    .. dynamic_value_internal( value.value, lifetime, env, obj, queries, names, updater )

	elseif value.type == DVALUE_CALL then
		local params = {}

		for i = 1, #value.parameters do
			params[i] = dynamic_value_internal( value.parameters[i], lifetime, env, obj, queries, names, updater )
		end

		return dynamic_value_internal( value.value, lifetime, env, obj, queries, names, updater )
		    .. "(" .. table.concat( params, ", " ) .. ")"
	elseif value.type == DVALUE_INDEX then
		return dynamic_value_internal( value.value, lifetime, env, obj, queries, names, updater )
		    .. "(" .. dynamic_value_internal( value.index, lifetime, env, obj, queries, names, updater ) .. ")"

	elseif value.type == DVALUE_BINEXPR then
		return dynamic_value_internal( value.lvalue, lifetime, env, obj, queries, names, updater )
		    .. " " .. value.operator .. " "
		    .. dynamic_value_internal( value.rvalue, lifetime, env, obj, queries, names, updater )

	elseif value.type == DVALUE_DOTINDEX then
		if value.value.type == DVALUE_QUERY or value.value.type == DVALUE_DQUERY then
			return dynamic_value_query( value.value, value.index, lifetime, env, obj, queries, names, updater )

		elseif value.value.type == DVALUE_SELF then
			obj.values:subscribe( value.index, lifetime, updater )
			return "self." .. value.index

		elseif value.value.type == DVALUE_PARENT then
			queries.parent = {
				child = obj;
				value = obj.parent;
				index = value.index;
			}

			return "self.parent." .. value.index

		elseif value.value.type == DVALUE_IDENTIFIER then
			error "TODO: fix this error"

		elseif value.value.type == DVALUE_APPLICATION then
			error "TODO: fix this error"

		else
			error "TODO: fix this error"

		end
	elseif query.type == DVALUE_DQUERY then
		error "NYI"

	elseif query.type == DVALUE_DQUERY then
		error "NYI"

	else
		-- TODO: every other type of node
		error "TODO: fix this error"
	end
end

class "Codegen" {}

function Codegen.node_query( parsed_query )
	return load( "local n=...return " .. node_query_internal( parsed_query, "n" ), "query" )
end

function Codegen.dynamic_value( parsed_value, lifetime, env, obj, updater, default )
	local names = {}
	local queries = {}
	local script_value = dynamic_value_internal( parsed_value, lifetime, env, obj, queries, names, updater )
	local names_n, names_v = { "self" }, {}
	local queries_t, queries_p = {}, {}

	for i = 1, #queries do
		queries_t[i] = queries[i].result[1]
		queries_p[i] = queries[i].index
	end

	for i = 1, #names do
		names_n[i + 1] = "n" .. i
		names_v[i] = names[i]
	end

	local f, err = assert( load( GENERIC_GETTER_FUNCTION:format( table.concat( names_n, ", " ), script_value ), "dynamic value" ) )

	return f( lifetime, updater, default, queries_p, queries_t, obj, unpack( names_v ) ), queries
end

function Codegen.dynamic_property_setter( property, options )
	cache[property] = cache[property] or {}
	options = options or {}
	options.parent_changed = options.parent_changed == nil or options.parent_changed

	local t1 = {}
	local t2 = {}
	local t3 = {}
	local t4 = {}

	if options.update_canvas_width then
		t4[#t4 + 1] = "self.canvas:set_width( self.width )"
		options.self_changed = true
	end
	if options.update_canvas_height then
		t4[#t4 + 1] = "self.canvas:set_height( self.height )"
		options.self_changed = true
	end

	if options.self_changed then
		t4[#t4 + 1] = "if not self.changed then self:set_changed() end"
	elseif options.parent_changed then
		t4[#t4 + 1] = "if self.parent and not self.parent.changed then self.parent:set_changed() end"
	end

	if options.self_changed or options.parent_changed then
		t4[#t4 + 1] = "if self.parent then self.parent:child_value_changed( self ) end"
	end

	if options.text_value then
		t1[#t1 + 1] = "if value:sub( 1, 1 ) == '!' then value = value:sub( 2 ) else value = ('%q'):format( value ) end"
	end

	t4[#t4 + 1] = options.custom_update_code

	local s4 = table.concat( t4, "\n" ) -- code to run on value update
	local s3 = table.concat( t3, "\n" ) -- code to update the AST
	local s2 = table.concat( t2, "\n" ) -- code to change the environment
	local s1 = table.concat( t1, "\n" ) -- code to update the string value

	for i = 1, #cache[property] do
		local c = cache[property][i]
		if c[1] == s1 and c[2] == s2 and c[3] == s3 and c[4] == s4 then
			return c.f
		end
	end

	local str = GENERIC_SETTER:format( property, "raw_" .. property, property, s4, property, s1, s2, s3, property, property, s4, property )
	local f = assert( (load or loadstring)( str, "property '" .. property .. "'", nil, _ENV ) )

	if setfenv then
		setfenv( f, getfenv() )
	end

	local fr = f()

	cache[property][#cache[property] + 1] = { s1, s2, s3, s4, f = fr }

	return fr
end
