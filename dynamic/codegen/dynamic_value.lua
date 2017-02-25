
 -- @include codegen.node_query

 -- @print including(dynamic.codegen.dynamic_value)
 -- @localise dynamic_value_codegen

local SELF_INDEX_UPDATER, ARBITRARY_DOTINDEX_UPDATER, ARBITRARY_INDEX_UPDATER,
      DYNAMIC_QUERY_UPDATER, QUERY_UPDATER

local function basic_value( value, update )
	return {
		value = value;
		complex = false;
		update = update or nil;
		initialise = nil;
		dependants = {};
		dependencies = {};
	}
end

local function dynamic_value_internal( value, state )
	if not value then return error "here" end
	if value.type == DVALUE_INTEGER
	or value.type == DVALUE_FLOAT
	or value.type == DVALUE_BOOLEAN then
		return basic_value( tostring( value.value ) )

	elseif value.type == DVALUE_STRING then
		return basic_value( ("%q"):format( value.value ) )

	elseif value.type == DVALUE_SELF then
		return basic_value "self"

	elseif value.type == DVALUE_PARENT then
		if state.object:type_of( Application ) then
			error "TODO: fix this error"
		else
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
		end

	elseif value.type == DVALUE_APPLICATION then
		if state.object:type_of( Application ) then
			return basic_value "self"

		else
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
		end

	elseif value.type == DVALUE_IDENTIFIER then
		if state.environment[value.value] ~= nil then
			state.inputs[#state.inputs + 1] = state.environment[value.value].value;
			return basic_value( "i" .. #state.inputs )
		else
			error "TODO: fix this error"
		end

	-- elseif value.type == DVALUE_PERCENTAGE then
	-- percentages will be resolved at the Typechecking stage

	elseif value.type == DVALUE_UNEXPR then
		local val = dynamic_value_internal( value.value, state )
		local n = #state.names + 1
		local t = basic_value( "n" .. n, "n" .. n .. " = " .. val.value .. " ~= nil and " .. value.operator .. " " .. val.value .. " or nil" )

		t.dependencies = { val }
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

		local t = basic_value( "n" .. n, "n" .. n .. " = " .. val.value .. " ~= nil and " .. table.concat( params_strval, " ~= nil and " ) .. " ~= nil and " .. val.value .. "(" .. table.concat( params_strval, ", " ) .. ") or nil" )

		t.dependencies = { val, unpack( params ) }
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
		local t = basic_value( "n" .. n, "n" .. n .. " = " .. (
			   (value.operator == "or" and lvalue.value .. " or " .. rvalue.value)
			or (value.operator == "and" and lvalue.value .. " and " .. rvalue.value .. " or nil")
			-- or value.operator == "==" and "" -- potentially $abc == $def == true if both are undefined
			-- or value.operator == "~=" and "" -- potentially $abc != $def == true if one is undefined and false if both are undefined
			or (lvalue.value .. " ~= nil and " .. rvalue.value .. " ~= nil and " .. lvalue.value .. " " .. value.operator .. " " .. rvalue.value .. " or nil")
	 	) )

		t.dependencies = { lvalue, rvalue };
		state.names[n] = "n" .. n
		lvalue.dependants[#lvalue.dependants + 1] = t
		rvalue.dependants[#rvalue.dependants + 1] = t

		return t

	elseif value.type == DVALUE_DOTINDEX then
		local val = dynamic_value_internal( value.value, state )
		local nr = #state.names + 1
		local nu = #state.names + 2
		local t = {
			value = ValueHandler.properties[value.index].transitionable
				and "(n" .. nr .. " and n" .. nr .. ".values:get_final_property_value('" .. value.index .. "'))"
				 or "(n" .. nr .. " and n" .. nr .. "." .. value.index .. ")";
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

	elseif value.type == DVALUE_FLOOR then
		local val = dynamic_value_internal( value.value, state )
		local n = #state.names + 1
		local t = basic_value( "n" .. n, "n" .. n .. " = " .. val.value .. " ~= nil and floor( " .. val.value .. " ) or nil" )

		t.dependencies = { val }
		state.names[n] = "n" .. n
		val.dependants[#val.dependants + 1] = t
		state.floored = true

		return t

	elseif value.type == DVALUE_TOSTRING then
		local val = dynamic_value_internal( value.value, state )
		local n = #state.names + 1
		local t = basic_value( "n" .. n, "n" .. n .. " = " .. val.value .. " ~= nil and tostring( " .. val.value .. " ) or nil" )

		t.dependencies = { val };
		state.names[n] = "n" .. n
		val.dependants[#val.dependants + 1] = t
		state.tostringed = true

		return t

	elseif value.type == DVALUE_TAG_CHECK then
		local val = dynamic_value_internal( value.value, state )
		local nidx = #state.names + 1
		local nval = #state.names + 2
		local npdt = #state.names + 3
		local t = {
			value = "n" .. nval;
			complex = true;
			update = "f" .. npdt .. "()";
			initialise = nil;
			dependants = {};
			dependencies = { val };
		}

		state.names[nidx] = "n" .. nidx
		state.names[nval] = "n" .. nval
		state.names[npdt] = "f" .. npdt
		state.functions[#state.functions + 1] = {
			code = TAG_CHECK_UPDATER
				:gsub( "NAME", "n" .. nidx )
				:gsub( "TAG", ("%q"):format( value.tag ) )
				:gsub( "FUNC", "f" .. npdt )
				:gsub( "LVALUE", val.value )
				:gsub( "VALUE", "n" .. nval );
			node = t;
		}

		val.dependants[#val.dependants + 1] = t

		return t

	else
		-- TODO: every other type of node
		error "TODO: fix this error"
	end
end

function dynamic_value_codegen( parsed_value, lifetime, env, obj, updater )
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

	local i = 1
	while i <= #roots do
		initialisers[#initialisers + 1] = roots[i].initialise or roots[i].update

		if not roots[i].complex then
			for n = 1, #roots[i].dependants do
				roots[#roots + 1] = roots[i].dependants[n]
			end
		end

		i = i + 1
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
		.. (state.tostringed and "local tostring = tostring\n" or "")
		.. (state.floored and "local floor = math.floor\n" or "")
	    .. (#names > 0 and "local " .. table.concat( names, ", " ) .. "\n" or "")
		.. table.concat( func_compiled, "\n" ) .. "\n"
		.. "return function() return " .. return_value.value .. " end, "
		.. (initialise_function or "function()\n"
			.. table.concat( initialisers, "\n" )
			.. (#initialisers == 0 and "" or "\n") .. "end")

	if parsed_value.type == DVALUE_BINEXPR and parsed_value.lvalue.lvalue and parsed_value.lvalue.lvalue.type == DVALUE_TAG_CHECK then
		local h = fs.open( "demo/log.txt", "w" )
		h.write( code )
		h.close()
	end

	local env = setmetatable( {  }, { __index = _ENV or getfenv() } )
	local f, err = assert( (load or loadstring)( code, "dynamic value", nil, env ) )

	if setfenv then
		setfenv( f, env )
	end

	local getter, initialiser = f( obj, lifetime, updater, unpack( inputs ) )
	return getter, initialiser
end

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

TAG_CHECK_UPDATER = [[do
	local function f0()
		VALUE = NAME and NAME:has_tag TAG
		DEPENDENCIES
	end

	function FUNC()
		local obj = LVALUE

		if NAME then
			NAME:unsubscribe_from_tag( TAG, f0 )
		end

		if obj then
			obj:subscribe_to_tag( TAG, lifetime, f0 )
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
			elems, ID = object:preparsed_query_tracked( QDATA, lifetime )
			object.query_tracker:subscribe( ID, lifetime, f0 )
		end

		PREVSOURCE = object
		return f0()
	end
end]]

QUERY_UPDATER = [[function FUNC()
	local object = SOURCE

	if object then
		local elems = object:preparsed_query( QDATA, lifetime )
		NAME = elems[1]

		if NAME then
			FUNC = function()end

			DEPENDENCIES
		end
	end
end]]
