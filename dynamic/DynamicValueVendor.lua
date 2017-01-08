
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.dynamic.DynamicValueVendor'
 -- @endif

 -- @print Including sheets.dynamic.DynamicValueVendor

class "DynamicValueVendor" {
	instance = nil;
	objects = {};
	attributes = {};
}

function DynamicValueVendor:DynamicValueVendor( instance )
	if not class.isInstance( instance ) then
		Exception.throw( IncorrectConstructorException( self.class:type() .. " expects Instance instance when created, got " .. class.type( instance ), 3 ) )
	end

	self.instance = instance
	self.objects = {}
	self.attributes = {}
end

function DynamicValueVendor:addAttribute( attribute, dependencies, setter, getter )
	parameters.check( 4, "attribute", "string", attribute, "dependencies", dependencies and "table" or "nil", dependencies, "setter", setter and "function" or "nil", setter, "getter", getter and "function" or "nil", getter )

	if self.attributes[attribute] then
		self.attributes[attribute].setter = setter
		self.attributes[attribute].getter = getter
	else
		self.attributes[attribute] = {
			setter = setter;
			getter = getter;
			dependencies = {};
			linked = {};
		}
	end

	return self:setAttributeDependencies( attribute, dependencies )
end

function DynamicValueVendor:setAttributeDependencies( attribute, dependencies )
	parameters.check( 2, "attribute", "string", attribute, "dependencies", dependencies and "table" or "nil", dependencies )

	local attributes = self.attributes
	local a = attributes[attribute]

	if not a then
		Exception.throw( DynamicValueException( "no such attribute '" .. attribute .. "'", 2 ) )
	end

	for i = 1, #a.dependencies do
		attributes[a.dependencies[i]].linked[attribute] = nil
	end

	a.dependencies = {}

	for i = 1, #dependencies do
		if not attributes[dependencies[i]] then
			Exception.throw( DynamicValueException( "no such dependency attribute '" .. attribute .. "'", 2 ) )
		elseif a.linked[dependencies[i]] then
			Exception.throw( DynamicValueException( "cyclic reference '" .. dependencies[i] .. "' <--> '" .. attribute .. "'", 2 ) )
		elseif dependencies[i] == attribute then
			Exception.throw( DynamicValueException( "self reference of '" .. attribute .. "'", 2 ) )
		end

		a.dependencies[i] = dependencies[i]
		attributes[ dependencies[i] ].linked[attribute] = true
	end

	self:updateAttribute( attribute )
end

function DynamicValueVendor:setAttributeSetter( attribute, setter )
	parameters.check( 2, "attribute", "string", attribute, "setter", setter and "function" or "nil", setter )

	if not self.attributes[attribute] then
		Exception.throw( DynamicValueException( "no such attribute '" .. attribute .. "'", 2 ) )
	end

	self.attributes[attribute].setter = setter

	self:updateAttribute( attribute )
end

function DynamicValueVendor:setAttributeGetter( attribute, getter )
	parameters.check( 2, "attribute", "string", attribute, "getter", getter and "function" or "nil", getter )

	if not self.attributes[attribute] then
		Exception.throw( DynamicValueException( "no such attribute '" .. attribute .. "'", 2 ) )
	end

	self.attributes[attribute].getter = getter

	self:updateAttribute( attribute )
end

function DynamicValueVendor:removeAttribute( attribute )
	parameters.check( 1, "attribute", "string", attribute )

	if not self.attributes[attribute] then
		return
	end

	local dependencies = self.attributes[attribute].dependencies
	local linked = self.attributes[attribute].linked

	for i = 1, #dependencies do
		self.attributes[dependencies[i]].linked[attribute] = nil
	end

	local k, v = next( linked )
	while k do
		self:removeAttribute( k )
		k, v = next( linked, k )
	end

end

function DynamicValueVendor:updateAttribute( attribute )
	parameters.check( 1, "attribute", "string", attribute )

	return self:setAttribute( attribute, self:getAttribute( attribute ) )
end

function DynamicValueVendor:setAttribute( attribute, value )

	parameters.check( 1, "attribute", "string", attribute )

	if not self.attributes[attribute] then
		Exception.throw( DynamicValueException( "no such attribute '" .. attribute .. "'", 2 ) )
	end

	local a = self.attributes[attribute]

	if a.setter then
		a.setter( self.instance, value )
	else
		self.instance[attribute] = value
	end

	local k, v = next( a.linked )
	while k do
		self:updateAttribute( k )
		k, v = next( a.linked, k )
	end
	
end

function DynamicValueVendor:getAttribute( attribute )

	parameters.check( 1, "attribute", "string", attribute )

	if not self.attributes[attribute] then
		Exception.throw( DynamicValueException( "no such attribute '" .. attribute .. "'", 2 ) )
	end

	local a = self.attributes[attribute]

	if a.getter then
		return a.getter( self.instance )
	else
		return self.instance[attribute]
	end

end

function DynamicValueVendor:wrapSetter( attribute )

	parameters.check( 1, "attribute", "string", attribute )

	return function( instance, value )
		return self:setAttribute( attribute, value )
	end

end

DynamicValueVendor.set = DynamicValueVendor.setAttribute
DynamicValueVendor.get = DynamicValueVendor.getAttribute
