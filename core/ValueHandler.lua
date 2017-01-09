
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
	self.object[name] = default
	self.object["raw_" .. name] = default
	self.lifetimes[name] = {}
	self.values[name] = type
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
		l[1].values:unsubscribe( l[2], l[3] )
	end

	self.lifetimes[name] = {}
end

function ValueHandler:subscribe( name, lifetime, callback )
	self.subscriptions[name] = self.subscriptions[name] or {}

	local t = self.subscriptions[name]

	t[#t + 1] = callback
	lifetime[#lifetime + 1] = { self.object, name, callback }
end

function ValueHandler:unsubscribe( name, callback )
	if self.subscriptions[name] then
		for i = #self.subscriptions[name], 1, -1 do
			if self.subscriptions[name][i] == callback then
				table.remove( self.subscriptions[name], i )
			end
		end
	end
end
