
 -- @include lib.lifetime

 -- @print including(dynamic.ValueHandler)

local floor = math.floor
local TRANSITION_FUNCTION_CODE
local tfcache = {}
local setf

@private
@class ValueHandler {
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

function ValueHandler:ValueHandler( object )
	self.object = object
	self.lifetimes = {}
	self.values = {}
	self.subscriptions = {}
	self.defaults = {}
	self.removed_lifetimes = {}
	self.transitions = {}
	self.transitions_lookup = {}
end

function ValueHandler:add( name, default )
	self.values[#self.values + 1] = name
	self.defaults[name] = default
	self.lifetimes[name] = {}
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
		for i = #self.subscriptions[name], 1, -1 do
			self.subscriptions[name][i]()
		end
	end
end

function ValueHandler:respawn( name )
	lifetimelib.destroy( self.lifetimes[name] )
	self.lifetimes[name] = {}
end

function ValueHandler:subscribe( name, lifetime, callback )
	self.subscriptions[name] = self.subscriptions[name] or {}
	lifetime[#lifetime + 1] = { "value", self, name, callback }

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

function ValueHandler:is_transitioning( property )
	return self.transitions_lookup[property] ~= nil
end

function ValueHandler:get_final_property_value( property )
	local trans = self.transitions[self.transitions_lookup[property]]
	return trans and trans.final or self.object[property]
end

function ValueHandler:get_transition_timeout( property )
	local trans = self.transitions[self.transitions_lookup[property]]
	return trans.duration - trans.clock
end

function ValueHandler:transition( property, final, transition, custom_update, dt_scale )
	local index = self.transitions_lookup[property] or #self.transitions + 1
	local floored = false
	local ptype = ValueHandler.properties[property].type

	if ptype == Type.primitive.integer then
		floored = true
	elseif ptype ~= Type.primitive.number then
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
			dt_scale = dt_scale;
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
		trans.clock = trans.clock + dt * trans.dt_scale

		if trans.clock >= trans.duration then
			self.object[trans.property] = trans.final
			table.remove( self.transitions, i )
			self.transitions_lookup[trans.property] = nil

			for n = i, #self.transitions do
				self.transitions_lookup[self.transitions[i].property] = n
			end
		else
			local eased = trans.initial + trans.diff * trans.easing( trans.clock / trans.duration )
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

ValueHandler.properties.x = { type = Type.primitive.integer, change = "parent", transitionable = true }
ValueHandler.properties.y = { type = Type.primitive.integer, change = "parent", transitionable = true }
ValueHandler.properties.z = { type = Type.primitive.integer, change = "parent", transitionable = true }

ValueHandler.properties.x_offset = { type = Type.primitive.integer, change = "self", transitionable = true }
ValueHandler.properties.y_offset = { type = Type.primitive.integer, change = "self", transitionable = true }

ValueHandler.properties.width = { type = Type.primitive.integer, change = "self", transitionable = true }
ValueHandler.properties.height = { type = Type.primitive.integer, change = "self", transitionable = true }

ValueHandler.properties.text = { type = Type.primitive.string, change = "self", transitionable = false }
ValueHandler.properties.line_count = { type = Type.primitive.integer, change = "none", transitionable = false }

ValueHandler.properties.horizontal_alignment = { type = Type.sheets.alignment, change = "self", transitionable = false }
ValueHandler.properties.vertical_alignment = { type = Type.sheets.alignment, change = "self", transitionable = false }

ValueHandler.properties.colour = { type = Type.sheets.colour, change = "self", transitionable = false }
ValueHandler.properties.text_colour = { type = Type.sheets.colour, change = "self", transitionable = false }

ValueHandler.properties.active = { type = Type.primitive.boolean, change = "self", transitionable = false }
ValueHandler.properties.active_colour = { type = Type.sheets.colour, change = "self", transitionable = false }

ValueHandler.properties.parent = { type = Type.sheets.optional_Sheet, change = "parent", transitionable = false }

TRANSITION_FUNCTION_CODE = [[
return function( self, value )
	self.PROPERTY_transition = value
	return self
end]]
