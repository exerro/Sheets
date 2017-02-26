
 -- @include codegen.dynamic_value
 -- @include codegen.node_query

 -- @print including(dynamic.codegen.dynamic_setter)

local CHANGECODE_NO_TRANSITION, CHANGECODE_TRANSITION, GENERIC_SETTER,
      STRING_CASTING, RAW_STRING_CASTING, INTEGER_CASTING, RAW_INTEGER_CASTING,
	  NUMBER_CASTING, RAW_NUMBER_CASTING, COLOUR_CASTING, RAW_COLOUR_CASTING,
	  ALIGNMENT_CASTING, RAW_ALIGNMENT_CASTING, ERR_CASTING

 -- @localise dynamic_property_setter_codegen
function dynamic_property_setter_codegen( property, options, environment )
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
				:gsub( "CUSTOM_UPDATE", "function( self )\n" .. s4 .. "\nend" )
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
		:gsub( "DEFINED_PROPERTY", ("%q"):format( property .. "_is_defined" ) )
		:gsub( "VALUE_MODIFICATION", function() return s1 end )
		:gsub( "ENV_MODIFICATION", function() return s2 end )
		:gsub( "AST_MODIFICATION", function() return s3 end )
		:gsub( "CASTING_RAW", function() return rawcaster end )
		:gsub( "CASTING", function() return caster end )
		:gsub( "TRANSITIONS", function() return ValueHandler.properties[property].transitionable and "true" or "false" end )
	local env = setmetatable( { Typechecking = Typechecking, Type = Type, dynamic_value_codegen = dynamic_value_codegen, DynamicValueParser = DynamicValueParser, surface = surface, Stream = Stream, lifetimelib = lifetimelib }, { __index = _ENV or getfenv() } )
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
if self.values:get_final_property_value PROPERTY_QUOTED ~= value then
	local dt_scale = 1
	local refs = lifetimelib.get_value_references( self.values.lifetimes[PROPERTY_QUOTED] )

	for i = 1, #refs do
		if refs[i][1]:is_transitioning( refs[i][2] ) then
			local scale = self[PROPERTY_TRANSITION_QUOTED].duration / refs[i][1]:get_transition_timeout( refs[i][2] )
			if scale < dt_scale then
				dt_scale = scale
			end
		end
	end

	self.values:transition( PROPERTY_QUOTED, value, self[PROPERTY_TRANSITION_QUOTED], CUSTOM_UPDATE, dt_scale )
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

GENERIC_SETTER = [[
local rtype, percentage_ast, environment = ...
return function( self, value, dont_set )
	self.values:respawn PROPERTY_QUOTED
	self[RAW_PROPERTY] = value

	if type( value ) ~= "string" then
		local value_type = Typechecking.resolve_type( value )

		if not (value_type == rtype) then
			CASTING_RAW
		end

		CHANGECODE

		self[DEFINED_PROPERTY] = not dont_set

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

			self[DEFINED_PROPERTY] = not dont_set
		end
	end

	if not parser.stream:is_EOF() then
		error "TODO: fix this error"
	end

	setter_f, initialiser_f = dynamic_value_codegen( value_parsed, lifetime, environment, self, update, TRANSITIONS )

	initialiser_f()
	update()

	return self
end]]
