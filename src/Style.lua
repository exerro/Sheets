
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Style'
 -- @endif

 -- @print Including sheets.Style

local function formatFieldName( name )
	if not name:find "%." then
		return name .. ".default"
	end
	return name
end

local function getDefaultFieldName( name )
	return name:gsub( "%..-$", "", 1 ) .. ".default"
end

local template = {}

class "Style" {
	fields = {};
	object = nil;
}

function Style.addToTemplate( cls, fields )
	if not class.isClass( cls ) then throw( IncorrectParameterException( "expected Class class, got " .. class.type( cls ), 2 ) ) end
	if type( fields ) ~= "table" then throw( IncorrectParameterException( "expected table fields, got " .. class.type( fields ), 2 ) ) end

	template[cls] = template[cls] or {}
	for k, v in pairs( fields ) do
		template[cls][formatFieldName( k )] = v
	end
end

function Style:Style( object )
	if not class.isInstance( object ) then throw( IncorrectConstructorException( "Style expects Instance object when created, got " .. class.type( object ), 3 ) ) end

	template[object.class] = template[object.class] or {}
	self.fields = {}
	self.object = object
end

function Style:clone( object )
	if not class.isInstance( object ) then throw( IncorrectInitialiserException( "expected Instance object, got " .. class.type( object ), 2 ) ) end

	local s = Style( object or self.object )
	for k, v in pairs( self.fields ) do
		s.fields[k] = v
	end
	return s
end

function Style:setField( field, value )
	functionParameters.check( 1, "field", "string", field )

	self.fields[formatFieldName( field )] = value
	self.object:setChanged()
	return self
end

function Style:getField( field )
	functionParameters.check( 1, "field", "string", field )

	field = formatFieldName( field )
	local default = getDefaultFieldName( field )
	if self.fields[field] ~= nil then
		return self.fields[field]
	elseif template[self.object.class][field] ~= nil then
		return template[self.object.class][field]
	elseif self.fields[default] ~= nil then
		return self.fields[default]
	else
		return template[self.object.class][default]
	end
end
