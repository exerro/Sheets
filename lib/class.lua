
-- @localise class
class = {}

local classobj = setmetatable( {}, { __index = class } )
local supported_meta_methods = { __add = true, __sub = true, __mul = true, __div = true, __mod = true, __pow = true, __unm = true, __len = true, __eq = true, __lt = true, __lte = true, __tostring = true, __concat = true }

local function _tostring( self )
	return "[Class] " .. self:type()
end

local function _concat( a, b )
	return tostring( a ) .. tostring( b )
end

local function _instance_tostring( self )
	return "[Instance] " .. self:type()
end

local function new_super( object, super )

	local super_proxy = {}

	if super.super then
		super_proxy.super = new_super( object, super.super )
	end

	setmetatable( super_proxy, { __index = function( t, k )

		if type( super[k] ) == "function" then
			return function( self, ... )

				if self == super_proxy then
					self = object
				end
				object.super = super_proxy.super
				local v = { super[k]( self, ... ) }
				object.super = super_proxy
				return unpack( v )

			end
		else
			return super[k]
		end

	end, __newindex = super, __tostring = function( self )
		return "[Super] " .. tostring( super ) .. " of " .. tostring( object )
	end } )

	return super_proxy

end

function classobj:new( ... )

	local mt = { __index = self, __INSTANCE = true }
	local instance = setmetatable( { class = self, meta = mt }, mt )

	if self.super then
		instance.super = new_super( instance, self.super )
	end

	for k, v in pairs( self.meta ) do
		if supported_meta_methods[k] then
			mt[k] = v
		end
	end

	if mt.__tostring == _tostring then
		function mt:__tostring()
			return self:tostring()
		end
	end

	function instance:type()
		return self.class:type()
	end

	function instance:type_of( class )
		return self.class:type_of( class )
	end

	function instance:implements( interface )
		return self.class:implements( interface )
	end

	if not self.tostring then
		instance.tostring = _instance_tostring
	end

	local ob = self
	while ob do
		if ob[ob.meta.__type] then
			ob[ob.meta.__type]( instance, ... )
			break
		end
		ob = ob.super
	end

	return instance

end

function classobj:type()
	return tostring( self.meta.__type )
end

function classobj:type_of( super )
	return super == self or ( self.super and self.super:type_of( super ) ) or false
end

function classobj:implements( interface )
	return self.__interface_list[interface] == true
end

function class.new( name, super, ... )
	local implements = { ... }
	local len = #implements
	local implements_lookup = {}

	if type( name ) ~= "string" then
		return error( "expected string class name, got " .. type( name ) )
	end

	local mt = { __index = classobj, __CLASS = true, __tostring = _tostring, __concat = _concat, __call = classobj.new, __type = name }
	local obj = setmetatable( { meta = mt, __interface_list = implements_lookup }, mt )

	if super then
		obj.super = super
		obj.meta.__index = super

		for interface in pairs( super.__interface_list ) do
			implements_lookup[interface] = true
		end
	end

	for i = 1, len do
		implements_lookup[implements[i]] = true
		for k, v in pairs( implements[i] ) do
			if k ~= "__interface_list" then
				obj[k] = v
			end
		end
		for interface in pairs( implements[i].__interface_list ) do
			implements_lookup[interface] = true
		end
	end

	return function( t )
		for k, v in pairs( t ) do
			obj[k] = v
		end
		return obj
	end
end

function class.type( object )
	local _type = type( object )

	if _type == "table" then
		pcall( function()
			local mt = getmetatable( object )
			_type = ( ( mt.__CLASS or mt.__INSTANCE ) and object:type() ) or _type
		end )
	end

	return _type
end

function class.type_of( object, class )
	if type( object ) == "table" then
		local ok, v = pcall( function()
			return getmetatable( object ).__CLASS or getmetatable( object ).__INSTANCE or error()
		end )
		return ok and object:type_of( class )
	end

	return false
end

function class.is_class( object )
	return pcall( function() if not getmetatable( object ).__CLASS then error() end end ), nil
end

function class.is_instance( object )
	return pcall( function() if not getmetatable( object ).__INSTANCE then error() end end ), nil
end

setmetatable( class, {
	__call = class.new;
} )

function class.new_interface( name, ... )
	local implements = { ... }
	local implements_lookup = {}
	local obj = { __interface_list = implements_lookup }
	local len = #implements

	for i = 1, len do
		implements_lookup[implements[i]] = true
		for k, v in pairs( implements[i] ) do
			if k ~= "__interface_list" then
				obj[k] = v
			end
		end
		for interface in pairs( implements[i].__interface_list ) do
			implements_lookup[interface] = true
		end
	end

	return function( t )
		for k, v in pairs( t ) do
			obj[k] = v
		end
		return obj
	end
end

function class.new_enum( name )
	return function( t )
		return setmetatable( {}, { __index = t, __newindex = function( t, k, v )
			return error( "attempt to set enum index '" .. tostring( k ) .. "'" )
		end } )
	end
end
