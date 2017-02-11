
local property_cache = {}

local CHANGECODE_NO_TRANSITION, CHANGECODE_TRANSITION, SELF_INDEX_UPDATER,
      ARBITRARY_DOTINDEX_UPDATER, ARBITRARY_INDEX_UPDATER, DYNAMIC_QUERY_UPDATER,
	  QUERY_UPDATER, GENERIC_SETTER

local node_query_internal, dynamic_value_internal

class "Codegen" {}

function Codegen.node_query( parsed_query )
	return load( "local n=...return " .. node_query_internal( parsed_query, "n" ), "query" )
end

function Codegen.dynamic_value( parsed_value, lifetime, env, obj, updater )
	local names = {}
	local functions = {}
	local inputs = {}
	local state = {
		environment = env;
		object = obj;
		names = names;
		functions = functions;
		inputs = inputs;
	}
	if not parsed_value then return error "here" end
	local return_value = dynamic_value_internal( parsed_value, state )

	local roots = {}
	local roots_tocheck = { return_value }
	local i = 1
	local func_compiled = {}
	local initialisers = {}
	local initialise_function
	local input_names = {}

	for i = 1, #inputs do
		input_names[i] = "i" .. i
	end

	while i <= #roots_tocheck do
		local t = roots_tocheck[i]
		if #t.dependencies == 0 then
			roots[#roots + 1] = t
		else
			local added = false
			for n = 1, #t.dependencies do
				if t.dependencies[n].update or t.dependencies[n].initialise then
					roots_tocheck[#roots_tocheck + 1] = t.dependencies[n]
					added = true
				end
			end
			if not added then
				roots[#roots + 1] = t
			end
		end
		i = i + 1
	end

	for i = 1, #functions do
		local dependants = {}
		local tocheck = { functions[i].node }
		local index = 1
		local update_root = false

		while index <= #tocheck do
			if index ~= 1 then
				dependants[#dependants + 1] = tocheck[index].update
			end

			if index == 1 or not tocheck[index].complex then
				update_root = update_root or tocheck[index] == return_value

				local idx = #tocheck
				for n = 1, #tocheck[index].dependants do
					tocheck[idx + n] = tocheck[index].dependants[n]
				end
			end

			index = index + 1
		end

		if update_root then
			dependants[#dependants + 1] = "updater()"
		end

		if dependants[1] then
			dependants[#dependants] = "return " .. dependants[#dependants]
		end

		func_compiled[i] = functions[i].code:gsub( "DEPENDENCIES", table.concat( dependants, "\n" ) )
	end

	for i = 1, #roots do
		initialisers[#initialisers + 1] = roots[i].initialise or roots[i].update
	end

	local s = initialisers[#initialisers]

	if s and s:find "^f%d+%(%)" then
		if #initialisers == 1 then
			initialise_function = s:match "^f%d+"
		else
			initialisers[#initialisers] = "return " .. s
		end
	end

	local code
	     = "local self, lifetime, updater"
			.. (#inputs > 0 and ", " .. table.concat( input_names, ", ") or "")
			.. " = ...\n"
	    .. (#names > 0 and "local " .. table.concat( names, ", " ) .. "\n" or "")
		.. table.concat( func_compiled, "\n" ) .. "\n"
		.. "return function() return " .. return_value.value .. " end, "
		.. (initialise_function or "function()\n"
			.. table.concat( initialisers, "\n" )
			.. (#initialisers == 0 and "" or "\n") .. "end")

	do
		local h = fs.open( "demo/log.txt", "w" )

		h.write( code .. "\n" .. #roots_tocheck[1].dependencies )
		h.close()
	end

	local fenv = getfenv and getfenv() and _ENV
	local f, err = assert( (load or loadstring)( code, "dynamic value", nil, fenv ) )
	local getter, initialiser = (setfenv and setfenv( f, fenv ) or f)( obj, lifetime, updater, unpack( inputs ) )

	return getter, initialiser
end

function Codegen.dynamic_property_setter( property, options )
	property_cache[property] = property_cache[property] or {}
	options = options or {}

	local self_changed = ValueHandler.properties[property].change == "self"
	local parent_changed = ValueHandler.properties[property].change == "parent"
	local ptype = ValueHandler.properties[property].type

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

	if self_changed then
		t4[#t4 + 1] = "if not self.changed then self:set_changed() end"
	elseif parent_changed then
		t4[#t4 + 1] = "if self.parent then self.parent:set_changed() end"
	end

	if self_changed or parent_changed then
		t4[#t4 + 1] = "if self.parent then self.parent:child_value_changed( self ) end"
	end

	if ptype == ValueHandler.string_type then
		t1[#t1 + 1] = "if value:sub( 1, 1 ) == '!' then value = value:sub( 2 ) else value = ('%q'):format( value ) end"
	end

	t4[#t4 + 1] = options.custom_update_code

	local s4 = table.concat( t4, "\n" ) -- code to run on value update
	local s3 = table.concat( t3, "\n" ) -- code to update the AST
	local s2 = table.concat( t2, "\n" ) -- code to change the environment
	local s1 = table.concat( t1, "\n" ) -- code to update the string value

	for i = 1, #property_cache[property] do
		local c = property_cache[property][i]
		if c[1] == s1 and c[2] == s2 and c[3] == s3 and c[4] == s4 then
			return c.f
		end
	end

	--[[
	function( self )
		ONCHANGE
	end
	]]

	local change_code

	if ValueHandler.properties[property].transitionable then
		change_code = CHANGECODE_TRANSITION

		if s4 ~= "" then
			change_code = change_code
				:gsub( "CUSTOM_UPDATE", ", function( self )\n" .. s4 .. "\nend" )
				:gsub( "PROPERTY_TRANSITION_QUOTED", ("%q"):format( property .. "_transition" ) )
		end
	else
		change_code = CHANGECODE_NO_TRANSITION
			:gsub( "ONCHANGE", s4 )
	end

	local prop_quoted = ("%q"):format( property )
	local str = GENERIC_SETTER
		:gsub( "CHANGECODE", change_code )
		:gsub( "PROPERTY_QUOTED", ("%q"):format( property ) )
		:gsub( "RAW_PROPERTY", ("%q"):format( "raw_" .. property ) )
		:gsub( "VALUE_MODIFICATION", function() return s1 end )
		:gsub( "ENV_MODIFICATION", function() return s2 end )
		:gsub( "AST_MODIFICATION", function() return s3 end )
		:gsub( "ONCHANGE", function() return s4 end )
	local f = assert( (load or loadstring)( str, "property setter '" .. property .. "'", nil, _ENV ) )

	if setfenv then
		setfenv( f, getfenv() )
	end

	local fr = f()

	property_cache[property][#property_cache[property] + 1] = { s1, s2, s3, s4, f = fr }

	return fr
end
CHANGECODE_NO_TRANSITION = [[
self[PROPERTY_QUOTED] = value
ONCHANGE
self.values:trigger PROPERTY_QUOTED]]

CHANGECODE_TRANSITION = [[
self.values:transition( PROPERTY_QUOTED, value, self[PROPERTY_TRANSITION_QUOTED]CUSTOM_UPDATE )]]

SELF_INDEX_UPDATER = [[function FUNC()
	NAME = self.INDEX
	DEPENDENCIES
end]]

ARBITRARY_DOTINDEX_UPDATER = [[do
	local function f0()
		DEPENDENCIES
	end

	function FUNC()
		local obj = LVALUE

		if NAME then
			NAME.values:unsubscribe( "INDEX", f0 )
		end

		if obj then
			obj.values:subscribe( "INDEX", lifetime, f0 )
		end

		NAME = obj
		return f0()
	end
end]]

ARBITRARY_INDEX_UPDATER = [[do
	local function f0()
		NAME = OLDVALUE and OLDINDEX and OLDVALUE[OLDINDEX]
		DEPENDENCIES
	end

	function FUNC()
		local obj = LVALUE
		local idx = INDEX

		if OLDVALUE and type( OLDINDEX ) == "string" then
			OLDVALUE.values:unsubscribe( OLDINDEX, f0 )
		end

		if obj and type( idx ) == "string" then
			obj.values:subscribe( idx, lifetime, f0 )
		end

		OLDVALUE = obj
		OLDINDEX = idx
		return f0()
	end
end]]

DYNAMIC_QUERY_UPDATER = [[do
	local elems, ID

	local function f0()
		NAME = elems and elems[1]
		DEPENDENCIES
	end

	function FUNC()
		local object = SOURCE

		if PREVSOURCE then
			PREVSOURCE.query_tracker:unsubscribe( ID, f0 )
		end

		if object then
			elems, ID = object:preparsed_query_tracked( QDATA )
			object.query_tracker:subscribe( ID, lifetime, f0 )
		end

		PREVSOURCE = object
		return f0()
	end
end]]

QUERY_UPDATER = [[function FUNC()
	local object = SOURCE

	if object then
		local elems = object:preparsed_query( QDATA )
		NAME = elems[1]

		if NAME then
			FUNC = function()end

			DEPENDENCIES
		end
	end
end]]

GENERIC_SETTER = [[
return function( self, value )
	self.values:respawn PROPERTY_QUOTED
	self[RAW_PROPERTY] = value

	if type( value ) ~= "string" then
		-- do type check

		CHANGECODE

		return self
	end

	VALUE_MODIFICATION

	local parser = DynamicValueParser( Stream( value ) )

	parser:set_context( "enable_queries", true )

	ENV_MODIFICATION

	local value_parsed = parser:parse_expression()
		or error "TODO: fix this error"

	AST_MODIFICATION

	local lifetime = self.values.lifetimes[PROPERTY_QUOTED]
	local default  = self.values.defaults[PROPERTY_QUOTED]
	local setter_f, initialiser_f

	local function update()
		local value = setter_f( self ) or default

		if value ~= self[PROPERTY_QUOTED] then
			CHANGECODE
		end
	end

	if not parser.stream:is_EOF() then
		error "TODO: fix this error"
	end

	setter_f, initialiser_f = Codegen.dynamic_value( value_parsed, lifetime, parser.environment, self, update )

	initialiser_f()
	update()

	return self
end]]

function node_query_internal( query, name )
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

function dynamic_value_internal( value, state )
	if not value then return error "here" end
	if value.type == DVALUE_INTEGER
	or value.type == DVALUE_FLOAT
	or value.type == DVALUE_BOOLEAN then
		return {
			value = tostring( value.value );
			complex = false;
			update = nil;
			initialise = nil;
			dependants = {};
			dependencies = {};
		}

	elseif value.type == DVALUE_STRING then
		return {
			value = ("%q"):format( value.value );
			complex = false;
			update = nil;
			initialise = nil;
			dependants = {};
			dependencies = {};
		}

	elseif value.type == DVALUE_SELF then
		return {
			value = "self";
			complex = false;
			update = nil;
			initialise = nil;
			dependants = {};
			dependencies = {};
		}

	elseif value.type == DVALUE_PARENT then
		local nr = #state.names + 1
		local nu = #state.names + 2
		local t = {
			value = "n" .. nr;
			complex = true;
			update = "f" .. nu .. "()";
			initialise = "self.values:subscribe( 'parent', lifetime, f" .. nu .. " )\nf" .. nu .. "()";
			dependants = {};
			dependencies = {};
		}

		state.names[nr] = "n" .. nr
		state.names[nu] = "f" .. nu
		state.functions[#state.functions + 1] = {
			code = SELF_INDEX_UPDATER:gsub( "NAME", "n" .. nr ):gsub( "INDEX", "parent" ):gsub( "FUNC", "f" .. nu );
			node = t;
		}

		return t

	elseif value.type == DVALUE_APPLICATION then
		local nr = #state.names + 1
		local nu = #state.names + 2
		local t = {
			value = "n" .. nr;
			complex = true;
			update = "f" .. nu .. "()";
			initialise = "self.values:subscribe( 'application', lifetime, f" .. nu .. " )\nf" .. nu .. "()";
			dependants = {};
			dependencies = {};
		}

		state.names[nr] = "n" .. nr
		state.names[nu] = "f" .. nu
		state.functions[#state.functions + 1] = {
			code = SELF_INDEX_UPDATER:gsub( "NAME", "n" .. nr ):gsub( "INDEX", "application" ):gsub( "FUNC", "f" .. nu );
			node = t;
		}

		return t

	elseif value.type == DVALUE_IDENTIFIER then
		if state.environment[value.value] ~= nil then
			state.inputs[#state.inputs + 1] = state.environment[value.value];

			return {
				value = "i" .. #state.inputs;
				complex = false;
				update = nil;
				initialise = nil;
				dependants = {};
				dependencies = {};
			}

		elseif state.object.values:has( value.value ) then
			local nr = #state.names + 1
			local nu = #state.names + 2
			local t = {
				value = "n" .. nr;
				complex = true;
				update = "f" .. nu .. "()";
				initialise = "self.values:subscribe( '" .. value.value .. "', lifetime, f" .. nu .. " )\nf" .. nu .. "()";
				dependants = {};
				dependencies = {};
			}

			state.names[nr] = "n" .. nr
			state.names[nu] = "f" .. nu
			state.functions[#state.functions + 1] = {
				code = SELF_INDEX_UPDATER:gsub( "NAME", "n" .. nr ):gsub( "INDEX", value.value ):gsub( "FUNC", "f" .. nu );
				node = t;
			}

			return t

		else
			error "TODO: fix this error"
		end

	elseif value.type == DVALUE_PERCENTAGE then
		error "NYI"

	elseif value.type == DVALUE_UNEXPR then
		local val = dynamic_value_internal( value.value, state )
		local n = #state.names + 1
		local t = {
			value = "n" .. n;
			complex = false;
			update = "n" .. n .. " = " .. val.value .. " ~= nil and " .. value.operator .. " " .. val.value .. " or nil";
			initialise = nil;
			dependants = {};
			dependencies = { val };
		}

		state.names[n] = "n" .. n
		val.dependants[#val.dependants + 1] = t

		return t

	elseif value.type == DVALUE_CALL then
		local val = dynamic_value_internal( value.value, state )
		local params = {}
		local params_strval = {}
		local n = #state.names + 1

		for i = 1, #value.parameters do
			params[i] = dynamic_value_internal( value.parameters[i], state )
			params_strval[i] = params[i].value
		end

		local t = {
			value = "n" .. n;
			complex = false;
			update = "n" .. n .. " = " .. val.value .. " ~= nil and " .. table.concat( params_strval, " ~= nil and " ) .. " ~= nil and " .. val.value .. "(" .. table.concat( params_strval, ", " ) .. ") or nil";
			initialise = nil;
			dependants = {};
			dependencies = { val, unpack( params ) };
		}

		state.names[n] = "n" .. n
		val.dependants[#val.dependants + 1] = t

		for i = 1, #params do
			params[i].dependants[#params[i].dependants + 1] = t
		end

		return t

	elseif value.type == DVALUE_INDEX then
		local val = dynamic_value_internal( value.value, state )
		local idx = dynamic_value_internal( value.index, state )
		local nval = #state.names + 1 -- copy of the value
		local nidx = #state.names + 2 -- copy of the index
		local nret = #state.names + 3 -- return value
		local npdt = #state.names + 4 -- updater function
		local t = {
			value = "n" .. nret;
			complex = true;
			update = "f" .. npdt .. "()";
			initialise = nil;
			dependants = {};
			dependencies = { val, idx };
		}

		val.dependants[#val.dependants + 1] = t;
		idx.dependants[#idx.dependants + 1] = t;
		state.names[nval] = "n" .. nval
		state.names[nidx] = "n" .. nidx
		state.names[nret] = "n" .. nret
		state.names[npdt] = "f" .. npdt
		state.functions[#state.functions + 1] = {
			code = ARBITRARY_INDEX_UPDATER
				:gsub( "NAME", "n" .. nret )
				:gsub( "FUNC", "f" .. npdt )
				:gsub( "OLDVALUE", "n" .. nval )
				:gsub( "OLDINDEX", "n" .. nidx )
				:gsub( "LVALUE", val.value )
				:gsub( "INDEX", idx.value );
			node = t;
		}

		return t

	elseif value.type == DVALUE_BINEXPR then
		local lvalue = dynamic_value_internal( value.lvalue, state )
		local rvalue = dynamic_value_internal( value.rvalue, state )
		local n = #state.names + 1
		local t = {
			value = "n" .. n;
			complex = false;
			update = "n" .. n .. " = " .. (
				(value.operator == "or" or value.operator == "and") and lvalue.value .. " " .. value.operator .. " " .. rvalue.value
				-- or value.operator == "==" and "" -- potentially $abc == $def == true if both are undefined
				-- or value.operator == "~=" and "" -- potentially $abc != $def == true if one is undefined and false if both are undefined
				or lvalue.value .. " ~= nil and " .. rvalue.value .. " ~= nil and " .. lvalue.value .. " " .. value.operator .. " " .. rvalue.value .. " or nil"
			);
			initialise = nil;
			dependants = {};
			dependencies = { lvalue, rvalue };
		}

		state.names[n] = "n" .. n
		lvalue.dependants[#lvalue.dependants + 1] = t
		rvalue.dependants[#rvalue.dependants + 1] = t

		return t

	elseif value.type == DVALUE_DOTINDEX then
		local val = dynamic_value_internal( value.value, state )
		local nr = #state.names + 1
		local nu = #state.names + 2
		local t = {
			value = "(n" .. nr .. " and n" .. nr .. "." .. value.index .. ")";
			complex = true;
			update = "f" .. nu .. "()";
			initialise = nil;
			dependants = {};
			dependencies = { val };
		}

		state.names[nr] = "n" .. nr
		state.names[nu] = "f" .. nu
		state.functions[#state.functions + 1] = {
			code = ARBITRARY_DOTINDEX_UPDATER
				:gsub( "NAME", "n" .. nr )
				:gsub( "INDEX", value.index )
				:gsub( "FUNC", "f" .. nu )
				:gsub( "LVALUE", val.value );
			node = t;
		}

		val.dependants[#val.dependants + 1] = t

		return t

	elseif value.type == DVALUE_QUERY then
		local val = dynamic_value_internal( value.source, state )
		local nret = #state.names + 1
		local npdt = #state.names + 2
		local t = {
			value = "n" .. nret;
			complex = true;
			update = "f" .. npdt .. "()";
			initialise = nil;
			dependants = {};
			dependencies = { val };
		}

		state.inputs[#state.inputs + 1] = value.query
		state.names[nret] = "n" .. nret
		state.names[npdt] = "f" .. npdt
		state.functions[#state.functions + 1] = {
			code = QUERY_UPDATER
				:gsub( "NAME", "n" .. nret )
				:gsub( "SOURCE", val.value )
				:gsub( "QDATA", "i" .. #state.inputs )
				:gsub( "FUNC", "f" .. npdt );
			node = t;
		}

		val.dependants[#val.dependants + 1] = t

		return t

	elseif value.type == DVALUE_DQUERY then
		local val = dynamic_value_internal( value.source, state )
		local nret = #state.names + 1
		local nsrc = #state.names + 2
		local npdt = #state.names + 3
		local t = {
			value = "n" .. nret;
			complex = true;
			update = "f" .. npdt .. "()";
			initialise = nil;
			dependants = {};
			dependencies = { val };
		}

		state.inputs[#state.inputs + 1] = value.query
		state.names[nret] = "n" .. nret
		state.names[nsrc] = "n" .. nsrc
		state.names[npdt] = "f" .. npdt
		state.functions[#state.functions + 1] = {
			code = DYNAMIC_QUERY_UPDATER
				:gsub( "NAME", "n" .. nret )
				:gsub( "PREVSOURCE", "n" .. nsrc )
				:gsub( "SOURCE", val.value )
				:gsub( "QDATA", "i" .. #state.inputs )
				:gsub( "FUNC", "f" .. npdt );
			node = t;
		}

		val.dependants[#val.dependants + 1] = t

		return t

	else
		-- TODO: every other type of node
		error "TODO: fix this error"
	end
end
