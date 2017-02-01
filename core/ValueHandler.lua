
 -- @once
 -- @print Including sheets.core.ValueHandler

class "ValueHandler" {
	object = nil;
	lifetimes = {};
	values = {};
	subscriptions = {};

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
