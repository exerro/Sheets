
 -- @once
 -- @print Including sheets.core.ValueHandler

local floor = math.floor
local get_transition_function
local TRANSITION_FUNCTION_CODE
local tfcache = {}
local setf

class "ValueHandler" {
	object = nil;
	lifetimes = {};
	values = {};
	subscriptions = {};
	defaults = {};
	removed_lifetimes = {};
	transitions = {};
	transitions_lookup = {};
}

ValueHandler.properties = {}
ValueHandler.integer_type = "integer";
ValueHandler.boolean_type = "boolean";
ValueHandler.number_type = "number";
ValueHandler.string_type = "string";
ValueHandler.colour_type = "colour";
ValueHandler.alignment_type = "alignment";
ValueHandler.optional_sheet_type = "sheet?";

function ValueHandler:ValueHandler( object )
	self.object = object
	self.lifetimes = {}
	self.values = {}
	self.subscriptions = {}
	self.defaults = {}
	self.removed_lifetimes = {}
	self.transitions = {}
	self.transitions_lookup = {}

	object.set = setf
end

function ValueHandler:add( name, default, options )
	if not ValueHandler.properties[name] then
		error "TODO: fix this error"
	end

	self.object["set_" .. name] = type( options ) == "function" and options or Codegen.dynamic_property_setter( name, options )
	self.object["raw_" .. name] = default
	self.object[name] = default
	self.values[#self.values + 1] = name
	self.defaults[name] = default
	self.lifetimes[name] = {}

	if ValueHandler.properties[name].transitionable then
		self.object["set_" .. name .. "_transition"] = get_transition_function( name )
		self.object[name .. "_transition"] = Transition.none
	end
end

function ValueHandler:remove( name )
	self.lifetimes[name] = nil
	self.values[name] = nil
	self.object[name] = nil
	self.object["raw_" .. name] = nil
	self.object["set_" .. name] = nil
end

function ValueHandler:has( name )
	return self.lifetimes[name] ~= nil
end

function ValueHandler:trigger( name )
	if self.subscriptions[name] then
		for i = 1, #self.subscriptions[name] do
			self.subscriptions[name][i]()
		end
	end
end

function ValueHandler:respawn( name )
	local t = self.lifetimes[name]

	for i = 1, #t do
		local l = t[i]
		if l[1] == "value" then
			l[2].values:unsubscribe( l[3], l[4] )
		elseif l[1] == "query" then
			l[2]:unsubscribe( l[3], l[4] )
		end
	end

	self.lifetimes[name] = {}
end

function ValueHandler:subscribe( name, lifetime, callback )
	self.subscriptions[name] = self.subscriptions[name] or {}
	lifetime[#lifetime + 1] = { "value", self.object, name, callback }

	local t = self.subscriptions[name]

	t[#t + 1] = callback

	return callback
end

function ValueHandler:unsubscribe( name, callback )
	if self.subscriptions[name] then
		for i = #self.subscriptions[name], 1, -1 do
			if self.subscriptions[name][i] == callback then
				table.remove( self.subscriptions[name], i )
				return callback
			end
		end
	end
end

function ValueHandler:child_removed()
	for k, v in pairs( self.lifetimes ) do
		self.removed_lifetimes[k] = v
		self:respawn( k )
	end
end

function ValueHandler:child_inserted()
	for k, v in pairs( self.removed_lifetimes ) do
		local lifetime = self.lifetimes[k]

		for i = 1, #v do
			if v[i][1] == "value" then
				v[i][2].values:subscribe( v[i][3], lifetime, v[i][4] )
			elseif v[i][1] == "query" then
				v[i][2]:subscribe( v[i][3], lifetime, v[i][4] )
			end
			v[i][4]()
		end
	end

	self.removed_lifetimes = {}
end

function ValueHandler:transition( property, final, transition, custom_update )
	local index = self.transitions_lookup[property] or #self.transitions + 1
	local floored = false -- TODO: make this respect the property
	local ptype = ValueHandler.properties[property].type

	if ptype == ValueHandler.integer_type then
		floored = true
	elseif ptype ~= ValueHandler.number_type then
		Exception.throw( Exception( "PropertyTransitionException", "Cannot animate non-number property '" .. property .. "'" ) ) -- TODO: make custom exception for this
	end

	final = floored and floor( final + 0.5 ) or final

	if transition ~= Transition.none and self.object.application then
		self.transitions_lookup[property] = index
		self.transitions[index] = {
			property = property;
			initial = self.object[property];
			final = final;
			diff = final - self.object[property];
			duration = transition.duration;
			clock = 0;
			easing = transition.easing_function;
			floored = floored;
			change = ValueHandler.properties[property].change;
			custom_update = custom_update;
		}
	else
		if self.object[property] ~= final then
			self.object[property] = final

			if ValueHandler.properties[property].change == "self" then
				self.object:set_changed()
			elseif ValueHandler.properties[property].change == "parent" and self.object.parent then
				self.object.parent:set_changed()
			end

			if custom_update then
				custom_update( self.object )
			end

			self:trigger( property )
		end
	end
end

function ValueHandler:update( dt )
	for i = #self.transitions, 1, -1 do
		local trans = self.transitions[i]
		trans.clock = trans.clock + dt

		if trans.clock >= trans.duration then
			self.object[trans.property] = trans.final
			table.remove( self.transitions, i )
			self.transitions_lookup[trans.property] = nil
		else
			local eased = trans.easing( trans.initial, trans.diff, trans.clock / trans.duration )
			self.object[trans.property] = trans.floored and floor( eased + 0.5 ) or eased
		end

		if trans.change == "self" then
			self.object:set_changed()
		elseif trans.change == "parent" and self.object.parent then
			self.object.parent:set_changed()
		end

		if trans.custom_update then
			trans.custom_update( self.object )
		end

		self:trigger( trans.property )
	end
end

ValueHandler.properties.x = { type = ValueHandler.integer_type, change = "parent", transitionable = true }
ValueHandler.properties.y = { type = ValueHandler.integer_type, change = "parent", transitionable = true }
ValueHandler.properties.z = { type = ValueHandler.integer_type, change = "parent", transitionable = true }

ValueHandler.properties.x_offset = { type = ValueHandler.integer_type, change = "self", transitionable = true }
ValueHandler.properties.y_offset = { type = ValueHandler.integer_type, change = "self", transitionable = true }

ValueHandler.properties.width = { type = ValueHandler.integer_type, change = "self", transitionable = true }
ValueHandler.properties.height = { type = ValueHandler.integer_type, change = "self", transitionable = true }

ValueHandler.properties.text = { type = ValueHandler.string_type, change = "self", transitionable = false }

ValueHandler.properties.horizontal_alignment = { type = ValueHandler.alignment_type, change = "self", transitionable = false }
ValueHandler.properties.vertical_alignment = { type = ValueHandler.alignment_type, change = "self", transitionable = false }

ValueHandler.properties.colour = { type = ValueHandler.colour_type, change = "self", transitionable = false }
ValueHandler.properties.text_colour = { type = ValueHandler.colour_type, change = "self", transitionable = false }
ValueHandler.properties.active_colour = { type = ValueHandler.colour_type, change = "self", transitionable = false }

ValueHandler.properties.parent = { type = ValueHandler.optional_sheet_type, change = "parent", transitionable = false }

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

TRANSITION_FUNCTION_CODE = [[
return function( self, value )
	self.PROPERTY_transition = value
	return self
end]]
