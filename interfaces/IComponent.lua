
 -- @include dynamic.codegen.dynamic_setter
 -- @include components.component

 -- @print including(interfaces.IComponent)

local setf
local copy_prop
local get_transition_function
local TRANSITION_FUNCTION_CODE

local function initialiser( self )
	self.values = ValueHandler( self )

	for k, v in pairs( self.properties ) do
		self.values:add( k, v.default )
		self[k] = v.default

		if ValueHandler.properties[k].transitionable then
			self.values:add( k .. "_transition", nil )
		end
	end

	self.set = setf
end

@private
@interface IComponent {
	lookup = nil;
	properties = nil;
}

function IComponent:initialise_properties() -- function overridden by IComponent:add_components()
	return error( "Class has not defined IComponent:add_components()", 0 )
end

function IComponent:add_components( ... )
	local comp = { ... }
	local lookup = self.lookup
	local properties = self.properties

	if self.super and properties == self.super.properties then
		properties = {}
		self.properties = properties

		for k, v in pairs( self.super.properties ) do
			properties[k] = copy_prop( v )
		end
	elseif not properties then
		properties = {}
		self.properties = properties
	end

	if self.super and lookup == self.super.lookup then
		lookup = {}
		self.lookup = lookup

		for k, v in pairs( self.super.lookup ) do
			lookup[k] = v
		end
	elseif not lookup then
		lookup = {}
		self.lookup = lookup
	end

	for i = #comp, 1, -1 do
		if type( comp[i] ) == "string" then
			comp[i] = components[comp[i]] or error( "component '" .. comp[i] .. "' could not be resolved", 2 )
		elseif type( comp[i] ) ~= "table" or not comp[i].__component then
			return error( "expected component, got " .. class.type( comp[i] ) )
		end
		if lookup[comp[i]] then
			table.remove( comp, i )
		end
	end

	local changed = component.combine( properties, lookup, unpack( comp ) )

	for property in pairs( changed ) do
		if not ValueHandler.properties[property] then
			error( "undefined property '" .. property .. "' from component '" .. properties[property].from.property .. "'", 2 )
		end

		local v = properties[property]
		local options = v.options
		local environment = v.environment
		local default = v.default
		local setter_function, unsetter_function

		if v.type == "property" or v.type == "setter" then
			if type( options ) == "table" or options == nil then
				setter_function = dynamic_property_setter_codegen( property, options or {}, environment )
			elseif type( options ) == "function" then
				setter_function = options
			else
				error( "invalid options type (" .. type( options ) .. ") for property '" .. property .. "' of component '" .. properties[property].from.property .. "'" )
			end

			unsetter_function = function( self )
				self[property] = default
				self[property .. "_is_defined"] = false
				return self
			end
		end

		self["set_" .. property] = setter_function
		self["unset_" .. property] = unsetter_function
		self["raw_" .. property] = default

		if ValueHandler.properties[property].transitionable then
			self["set_" .. property .. "_transition"] = get_transition_function( property )
			self[property .. "_transition"] = Transition.none
		end
	end

	self.initialise_properties = initialiser
end

function copy_prop( t )
	local options = {}
	local environment = {}

	if type( t.options ) == "table" then
		for k, v in pairs( t.options ) do
			options[k] = v
		end
	end

	for k, v in pairs( t.environment ) do
		environment[k] = v
	end

	return { type = t.type, options = options, environment = environment, default = t.default, from = t.from }
end

function get_transition_function( name )
	if not tfcache[name] then
		tfcache[name] = (load or loadstring)( TRANSITION_FUNCTION_CODE:gsub( "PROPERTY", name ) )()
	end

	return tfcache[name]
end

function setf( self, t )
	for k, v in pairs( t ) do
		if self["set_" .. k] then
			self["set_" .. k]( self, v )
		else
			-- TODO: error or just ignore?
		end
	end

	return self
end

-- TODO: make this support dynvals
TRANSITION_FUNCTION_CODE = [[
return function( self, value )
	self.PROPERTY_transition = value
	return self
end]]