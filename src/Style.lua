
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Style'
 -- @endif

 -- @print Including sheets.Style

local function formatPropertyName( name )
	if not name:find "%." then
		return name .. ".default"
	end
	return name
end

local function getDefaultPropertyName( name )
	return name:gsub( "%..-$", "", 1 ) .. ".default"
end

local template = {}

class "Style" {
	fields = {};
	object = nil;
}

function Style.addToTemplate( cls, properties )
	if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
	if type( properties ) ~= "table" then return error( "expected table fields, got " .. class.type( properties ) ) end

	template[cls] = template[cls] or {}
	for k, v in pairs( properties ) do
		template[cls][formatPropertyName( k )] = v
	end
end

function Style:Style( object )
	if not class.isInstance( object ) then return error( "Style attribute #1 'object' not an instance (" .. class.type( object ) .. ")", 2 ) end

	template[object.class] = template[object.class] or {}
	self.fields = {}
	self.object = object
end

function Style:clone( object )
	if not class.isInstance( object ) then return error( "expected Instance object, got " .. class.type( object ) ) end

	local s = Style( object or self.object )
	for k, v in pairs( self.fields ) do
		s.fields[k] = v
	end
	return s
end

function Style:setField( field, value )
	if type( field ) ~= "string" then return error( "expected string field, got " .. class.type( field ) ) end

	self.fields[formatPropertyName( field )] = value
	self.object:setChanged()
	return self
end

function Style:getField( field )
	if type( field ) ~= "string" then return error( "expected string field, got " .. class.type( field ) ) end

	field = formatPropertyName( field )
	local default = getDefaultPropertyName( field )
	return self.fields[field] or template[self.object.class][field] or self.fields[default] or template[self.object.class][default]
end
