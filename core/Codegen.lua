
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
local lifetime, updater, default, node_list, %s = ...
return function( self, i, value )
	if self then
		return %s or default
	else
		%s
		node_list[i] = value
		%s
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

local function dynamic_value_internal( value, state )
	if value.type == DVALUE_INTEGER
	or value.type == DVALUE_FLOAT
	or value.type == DVALUE_BOOLEAN then
		state.expressions[#state.expressions + 1] = tostring( value.value )
		return #state.expressions

	elseif value.type == DVALUE_STRING then
		state.expressions[#state.expressions + 1] = ("%q"):format( value.value )
		return #state.expressions

	elseif value.type == DVALUE_SELF then
		state.expressions[#state.expressions + 1] = "self"
		return #state.expressions

	elseif value.type == DVALUE_PARENT then
		state.tracking[#state.tracking + 1] = { type = "parent", object = obj }
		state.expressions[#state.expressions + 1] = "node_list[" .. #state.tracking .. "]"
		return #state.expressions

	elseif value.type == DVALUE_APPLICATION then
		state.tracking[#state.tracking + 1] = { type = "application", object = obj }
		state.expressions[#state.expressions + 1] = "node_list[" .. #state.tracking .. "]"
		return #state.expressions

	elseif value.type == DVALUE_IDENTIFIER then
		-- names[#names + 1] = env[value.value]
		-- return "n" .. #names

		error "NYI"

	elseif value.type == DVALUE_PERCENTAGE then
		error "NYI"

	elseif value.type == DVALUE_UNEXPR then
		local idx = dynamic_value_internal( value.value, state )
		state.expressions[#state.expressions + 1] = "n" .. idx .. "~=nil and " .. value.operator .. " n" .. idx
		return #state.expressions

	elseif value.type == DVALUE_CALL then
		local params = { "n" .. dynamic_value_internal( value.value, state ) }

		for i = 1, #value.parameters do
			params[i + 1] = "n" .. dynamic_value_internal( value.parameters[i], state )
		end

		state.expressions[#state.expressions + 1] = table.concat( params, "~=nil and " ) .. "~=nil and " .. params[1] .. "(" .. table.concat( params, ", ", 2 ) .. ")"

		return #state.expressions
	elseif value.type == DVALUE_INDEX then
		local lidx = dynamic_value_internal( value.value, state )
		local ridx = dynamic_value_internal( value.index, state )
		state.expressions[#state.expressions + 1] = "n" .. lidx .. "~=nil and " .. "n" .. ridx .. "~=nil and " .. " n" .. lidx .. "[n" .. ridx .. "]"
		return #state.expressions

	elseif value.type == DVALUE_BINEXPR then
		local lidx = dynamic_value_internal( value.lvalue, state )
		local ridx = dynamic_value_internal( value.rvalue, state )

		if value.operator == "or" or value.operator == "and" then
			state.expressions[#state.expressions + 1] = "n" .. lidx .. " " .. value.operator .. " n" .. ridx
		elseif value.operator == "==" or value.operator == "~=" then
			state.expressions[#state.expressions + 1] = "n" .. lidx .. value.operator .. "n" .. ridx
		else
			state.expressions[#state.expressions + 1] = "n" .. lidx .. "~=nil and " .. "n" .. ridx .. "~=nil and " .. " n" .. lidx .. " " .. value.operator .. " n" .. ridx
		end

		return #state.expressions

	elseif value.type == DVALUE_DOTINDEX then
		local idx = dynamic_value_internal( value.value, state )
		state.expressions[#state.expressions + 1] = "n" .. idx .. "~=nil and " .. "n" .. idx .. "." .. value.index
		return #state.expressions

	elseif value.type == DVALUE_QUERY then
		local substate = {
			lifetime = state.lifetime;
			env = state.env;
			obj = state.obj;
			tracking = state.tracking;
			names = state.names;
			expressions = {};
			updater = state.updater;
		}

		state.tracking[#state.tracking + 1] = { type = "query", object = obj, query = value.query, source = dynamic_value_internal( value.source, substate ), expressions = substate.expressions }
		state.expressions[#state.expressions + 1] = "node_list[" .. #state.tracking .. "]"
		return #state.expressions

	elseif value.type == DVALUE_DQUERY then
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
	local tracking = {}
	local expressions = {}
	local state = {
		lifetime = lifetime;
		env = env;
		obj = obj;
		tracking = tracking;
		names = names;
		expressions = expressions;
		updater = updater;
	}
	local return_index = dynamic_value_internal( parsed_value, state )
	local names_n, names_v = { "self" }, { obj }
	local node_list = {}
	local index_count = 0

	do return state end

	for i = 1, #tracking do
		if tracking[i].type == "dynamic query" then
			node_list[i] = tracking[i].result[1]
		end
	end

	for i = 1, #names do
		names_n[i + 1] = "n" .. i
		names_v[i] = names[i]
	end

	local s1 = ""
	local s2 = index_count == 0 and "" or "end" -- end if any dotindexes tracked

	local f, err = assert( load( GENERIC_GETTER_FUNCTION:format( table.concat( names_n, ", " ), script_value, s1, s2 ), "dynamic value" ) )

	return f( lifetime, updater, default, node_list, unpack( names_v ) ), tracking
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
