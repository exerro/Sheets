
 -- @once
 -- @print Including sheets.core.ValueHandler

local floor = math.floor

class "ValueHandler" {
	object = nil;
	lifetimes = {};
	values = {};
	subscriptions = {};
	defaults = {};
	removed_lifetimes = {};
	transitions = {};
	transitions_lookup = {};

	integer_type = "integer";
	boolean_type = "boolean";
	number_type = "number";
	string_type = "string";
}

function ValueHandler:ValueHandler( object )
	self.object = object
	self.lifetimes = {}
	self.values = {}
	self.subscriptions = {}
	self.defaults = {}
	self.removed_lifetimes = {}
	self.transitions = {}
	self.transitions_lookup = {}

	function object:set( t )
		for k, v in pairs( t ) do
			if self["set_" .. k] then
				self["set_" .. k]( self, v )
			else
				-- TODO: error or just ignore?
			end
		end

		return self
	end
end

function ValueHandler:add( name, type, default, setter )
	self.object["set_" .. name] = setter
	self.object["raw_" .. name] = default
	self.object[name] = default
	self.values[name] = type
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

function ValueHandler:transition( property, final, transition )
	local index = self.transitions_lookup[property] or #self.transitions + 1
	local floored = false -- TODO: make this respect the property

	if self.values[property] == ValueHandler.integer_type then
		floored = true
	elseif self.values[property] ~= ValueHandler.number_type then
		Exception.throw( Exception, "Cannot animate non-number property '" .. property .. "'" )
	end

	final = floored and floor( final + 0.5 ) or final

	if transition ~= Transition.none then
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
		}
	else
		if self.object[property] ~= val then
			self.object[property] = val
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

		self:trigger( trans.property )
	end
end
