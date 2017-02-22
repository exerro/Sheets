
 -- @print including(dynamic.Codegen)

local CHANGECODE_NO_TRANSITION, CHANGECODE_TRANSITION, SELF_INDEX_UPDATER,
      ARBITRARY_DOTINDEX_UPDATER, ARBITRARY_INDEX_UPDATER, DYNAMIC_QUERY_UPDATER,
	  QUERY_UPDATER, GENERIC_SETTER, STRING_CASTING, RAW_STRING_CASTING,
	  INTEGER_CASTING, RAW_INTEGER_CASTING, NUMBER_CASTING, RAW_NUMBER_CASTING,
	  COLOUR_CASTING, RAW_COLOUR_CASTING, ALIGNMENT_CASTING,
	  RAW_ALIGNMENT_CASTING, ERR_CASTING

local node_query_internal, dynamic_value_internal

@class Codegen {

}

function Codegen.node_query( parsed_query, lifetime, updater )
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
		initialise_code[i] = "f" .. i .. ", i" .. i .. " = Codegen.dynamic_value( n" .. i .. ", lifetime, env, n, function()\n"
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

	local env = setmetatable( { Codegen = Codegen }, { __index = _ENV or getfenv() } )
	local f, err = assert( (load or loadstring)( code, "query", nil, env ) )

	if setfenv then
		setfenv( f, env )
	end

	local getter, initialiser = f( lifetime, updater, unpack( named_values ) )
	return getter, initialiser
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

function Codegen.dynamic_property_setter( property, options, environment )
	local self_changed = ValueHandler.properties[property].change == "self"
	local parent_changed = ValueHandler.properties[property].change == "parent"
	local ptype = ValueHandler.properties[property].type

	local t1 = {} -- code to update the string value
	local t2 = {} -- code to change the environment
	local t3 = {} -- code to update the AST
	local t4 = {} -- code to run on value update
	local t5 = {} -- code to update the value before assignment

	if options.update_surface_size then
		t4[#t4 + 1] = "if self.surface then self.surface = surface.create( self.width, self.height ) end"
		self_changed = true
	end

	if self_changed then
		t4[#t4 + 1] = "if not self.changed then self:set_changed() end"
	elseif parent_changed then
		t4[#t4 + 1] = "if self.parent then self.parent:set_changed() end"
	end

	if self_changed or parent_changed then
		t4[#t4 + 1] = "if self.parent then self.parent:child_value_changed( self ) end"
	end

	if ptype == Type.primitive.string then
		t1[#t1 + 1] = "if value:sub( 1, 1 ) == '!' then value = value:sub( 2 ) else value = ('%q'):format( value ) end"
	end

	if options.percentages_enabled then
		t2[#t2 + 1] = "parser.flags.enable_percentages = true"
	end

	if ptype == Type.sheets.colour then
		for k, v in pairs( colour ) do
			environment[k] = { precalculated_type = ptype, value = v }
		end

		t5[#t5 + 1] = "if value == TRANSPARENT then value = nil end"
	end

	if ptype == Type.sheets.alignment then
		for k, v in pairs( alignment ) do
			environment[k] = { precalculated_type = ptype, value = v }
		end
	end

	t2[#t2 + 1] = options.custom_environment_code
	t4[#t4 + 1] = options.custom_update_code

	local s5 = table.concat( t5, "\n" )
	local s4 = table.concat( t4, "\n" )
	local s3 = table.concat( t3, "\n" )
	local s2 = table.concat( t2, "\n" )
	local s1 = table.concat( t1, "\n" )

	local change_code

	if ValueHandler.properties[property].transitionable then
		change_code = CHANGECODE_TRANSITION

		if s4 ~= "" then
			change_code = change_code
				:gsub( "CUSTOM_UPDATE", ", function( self )\n" .. s4 .. "\nend" )
				:gsub( "PROPERTY_TRANSITION_QUOTED", ("%q"):format( property .. "_transition" ) )
				:gsub( "PROCESS_VALUE", s5 )
		end
	else
		change_code = CHANGECODE_NO_TRANSITION
			:gsub( "ONCHANGE", s4 )
			:gsub( "PROCESS_VALUE", s5 )
	end

	local prop_quoted = ("%q"):format( property )
	local caster = ptype == Type.primitive.string and STRING_CASTING
	            or ptype == Type.primitive.integer and INTEGER_CASTING
				or ptype == Type.primitive.number and NUMBER_CASTING
				or ptype == Type.sheets.colour and COLOUR_CASTING
				or ptype == Type.sheets.alignment and ALIGNMENT_CASTING
				or ERR_CASTING
	local rawcaster = ptype == Type.primitive.string and RAW_STRING_CASTING
	               or ptype == Type.primitive.integer and RAW_INTEGER_CASTING
				   or ptype == Type.primitive.number and RAW_NUMBER_CASTING
				   or ptype == Type.sheets.colour and RAW_COLOUR_CASTING
				   or ptype == Type.sheets.alignment and RAW_ALIGNMENT_CASTING
				   or ERR_CASTING
	local str = GENERIC_SETTER
		:gsub( "CHANGECODE", change_code )
		:gsub( "PROPERTY_QUOTED", ("%q"):format( property ) )
		:gsub( "RAW_PROPERTY", ("%q"):format( "raw_" .. property ) )
		:gsub( "VALUE_MODIFICATION", function() return s1 end )
		:gsub( "ENV_MODIFICATION", function() return s2 end )
		:gsub( "AST_MODIFICATION", function() return s3 end )
		:gsub( "CASTING_RAW", function() return rawcaster end )
		:gsub( "CASTING", function() return caster end )
	local env = setmetatable( { Typechecking = Typechecking, Type = Type, Codegen = Codegen, DynamicValueParser = DynamicValueParser, surface = surface, Stream = Stream }, { __index = _ENV or getfenv() } )
	local f = assert( (load or loadstring)( str, "property setter '" .. property .. "'", nil, env ) )

	-- @if DEBUG
		local h = fs.open( ".sheets_debug/property_" .. property .. ".lua", "w" ) or error( property )
		h.write( str )
		h.close()
	-- @endif

	if setfenv then
		setfenv( f, env )
	end

	local fr = f( ptype, options.percentage_ast, environment )

	return fr
end

CHANGECODE_NO_TRANSITION = [[
PROCESS_VALUE
if self[PROPERTY_QUOTED] ~= value then
	self[PROPERTY_QUOTED] = value
	ONCHANGE
	self.values:trigger PROPERTY_QUOTED
end]]

CHANGECODE_TRANSITION = [[
PROCESS_VALUE
if self[PROPERTY_QUOTED] ~= value then
	self.values:transition( PROPERTY_QUOTED, value, self[PROPERTY_TRANSITION_QUOTED]CUSTOM_UPDATE )
end]]

STRING_CASTING = [[
if value_type == Type.primitive.integer or value_type == Type.primitive.number or value_type == Type.primitive.boolean then
	value_parsed = {
		type = DVALUE_TOSTRING;
		value = value_parsed;
	}
else
	error "TODO: fix this error"
end
]]

RAW_STRING_CASTING = [[
if value_type == Type.primitive.integer or value_type == Type.primitive.number or value_type == Type.primitive.boolean then
	value = tostring( value )
else
	error "TODO: fix this error"
end
]]

INTEGER_CASTING = [[
if value_type == Type.primitive.number then
	value_parsed = {
		type = DVALUE_FLOOR;
		value = value_parsed;
	}
else
	error "TODO: fix this error"
end
]]



RAW_INTEGER_CASTING = [[
if value_type == Type.primitive.number then
	value = math.floor( value )
else
	error "TODO: fix this error"
end
]]

NUMBER_CASTING = [[
if not (value_type == Type.primitive.integer) then
	error "TODO: fix this error"
end
]]

RAW_NUMBER_CASTING = NUMBER_CASTING

COLOUR_CASTING = [[
error "TODO: fix this error"
]]

RAW_COLOUR_CASTING = [[
if value_type == Type.primitive.integer then
	if value ~= TRANSPARENT and (math.log( value ) / math.log( 2 ) % 1 ~= 0 or value < 1 or value > 2 ^ 15) then
		error "TODO: fix this error"
	end
else
	error "TODO: fix this error"
end
]]

ALIGNMENT_CASTING = [[
error "TODO: fix this error"
]]

RAW_ALIGNMENT_CASTING = [[
if value_type == Type.primitive.integer then
	if value ~= ALIGNMENT_LEFT and value ~= ALIGNMENT_RIGHT and value ~= ALIGNMENT_TOP and value ~= ALIGNMENT_BOTTOM and value ~= ALIGNMENT_CENTRE then
		error "TODO: fix this error"
	end
else
	error "TODO: fix this error"
end
]]

ERR_CASTING = [[
error "TODO: fix this error"
]]

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

GENERIC_SETTER = [[
local rtype, percentage_ast, environment = ...
return function( self, value )
	self.values:respawn PROPERTY_QUOTED
	self[RAW_PROPERTY] = value

	if type( value ) ~= "string" then
		local value_type = Typechecking.resolve_type( value )

		if not (value_type == rtype) then
			CASTING_RAW
		end

		CHANGECODE

		return self
	end

	VALUE_MODIFICATION

	local parser = DynamicValueParser( Stream( value ) )

	parser.flags.enable_queries = true

	ENV_MODIFICATION

	local value_parsed = parser:parse_expression()
		or "TODO: fix this error"

	AST_MODIFICATION

	local value_parsed, value_type = Typechecking.check_type( value_parsed, {
		object = self;
		environment = environment;
		percentage_ast = percentage_ast;
	} )
	local lifetime = self.values.lifetimes[PROPERTY_QUOTED]
	local default  = self.values .defaults[PROPERTY_QUOTED]
	local setter_f, initialiser_f

	if not (value_type == rtype) then
		CASTING
	end

	local function update()
		local value = setter_f( self ) or default

		if value ~= self[PROPERTY_QUOTED] then
			CHANGECODE
		end
	end

	if not parser.stream:is_EOF() then
		error "TODO: fix this error"
	end

	setter_f, initialiser_f = Codegen.dynamic_value( value_parsed, lifetime, environment, self, update )

	initialiser_f()
	update()

	return self
end]]

function node_query_internal( query, name, tracked )
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
			return {
				value = "self";
				complex = false;
				update = nil;
				initialise = nil;
				dependants = {};
				dependencies = {};
			}

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

			return {
				value = "i" .. #state.inputs;
				complex = false;
				update = nil;
				initialise = nil;
				dependants = {};
				dependencies = {};
			}

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
				   (value.operator == "or" and lvalue.value .. " or " .. rvalue.value)
				or (value.operator == "and" and lvalue.value .. " and " .. rvalue.value .. " or nil")
				-- or value.operator == "==" and "" -- potentially $abc == $def == true if both are undefined
				-- or value.operator == "~=" and "" -- potentially $abc != $def == true if one is undefined and false if both are undefined
				or (lvalue.value .. " ~= nil and " .. rvalue.value .. " ~= nil and " .. lvalue.value .. " " .. value.operator .. " " .. rvalue.value .. " or nil")
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

	elseif value.type == DVALUE_FLOOR then
		local val = dynamic_value_internal( value.value, state )
		local n = #state.names + 1
		local t = {
			value = "n" .. n;
			complex = false;
			update = "n" .. n .. " = " .. val.value .. " ~= nil and floor( " .. val.value .. " ) or nil";
			initialise = nil;
			dependants = {};
			dependencies = { val };
		}

		state.names[n] = "n" .. n
		val.dependants[#val.dependants + 1] = t
		state.floored = true

		return t

	elseif value.type == DVALUE_TOSTRING then
		local val = dynamic_value_internal( value.value, state )
		local n = #state.names + 1
		local t = {
			value = "n" .. n;
			complex = false;
			update = "n" .. n .. " = " .. val.value .. " ~= nil and tostring( " .. val.value .. " ) or nil";
			initialise = nil;
			dependants = {};
			dependencies = { val };
		}

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
