
 -- @print Including sheets.class

class = {}
local classobj = setmetatable( {}, { __index = class } )
local names = {}
local interfaces = {}
local environment = _ENV or getfenv()
local last_created

local supported_meta_methods = { __add = true, __sub = true, __mul = true, __div = true, __mod = true, __pow = true, __unm = true, __len = true, __eq = true, __lt = true, __lte = true, __tostring = true, __concat = true }

local function _tostring( self )
	return "[Class] " .. self:type()
end
local function _concat( a, b )
	return tostring( a ) .. tostring( b )
end

local function construct( t )
	if not last_created then
		return error "no class to define"
	end

	for k, v in pairs( t ) do
		last_created[k] = v
	end
	last_created = nil
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

	if not self.tostring then
		function instance:tostring()
			return "[Instance] " .. self:type()
		end
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

function classobj:extends( super )
	self.super = super
	self.meta.__index = super
end

function classobj:type()
	return tostring( self.meta.__type )
end

function classobj:type_of( super )
	return super == self or ( self.super and self.super:type_of( super ) ) or false
end

function class:new( name )

	if type( name or self ) ~= "string" then
		return error( "expected string class name, got " .. type( name or self ) )
	end

	local mt = { __index = classobj, __CLASS = true, __tostring = _tostring, __concat = _concat, __call = classobj.new, __type = name or self }
	local obj = setmetatable( { meta = mt }, mt )

	names[name] = obj
	last_created = obj

	environment[name] = obj

	return function( t )
		if not last_created then
			return error "no class to define"
		end

		for k, v in pairs( t ) do
			last_created[k] = v
		end
		last_created = nil
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
		local ok, v = pcall( function() return getmetatable( object ).__CLASS or getmetatable( object ).__INSTANCE or error() end )
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

function class.get( name )
	return environment[name]
end

function class.set_environment( env )
	environment = env
	env.class = class
	env.extends = extends
	env.interface = interface
	env.implements = implements
	-- env.enum = enum -- TODO: enums would be cool
end

setmetatable( class, {
	__call = class.new;
} )

function extends( name )
	if not last_created then
		return error "no class to extend"
	elseif not names[name] then
		return error( "no such class '" .. tostring( name ) .. "'" )
	end

	last_created:extends( names[name] )

	return construct
end

function interface( name )
	interfaces[name] = {}
	environment[name] = interfaces[name]
	last_created = interfaces[name]
	return function( t )
		if type( t ) ~= "table" then
			return error( "expected table t, got " .. class.type( t ) )
		end
		environment[name] = t
		interfaces[name] = t
	end
end

function implements( name )
	if not last_created then
		return error "no class to modify"
	elseif not interfaces[name] then
		return error( "no interface by name '" .. tostring( name ) .. "'" )
	end

	for k, v in pairs( interfaces[name] ) do
		last_created[k] = v
	end

	return construct
end
