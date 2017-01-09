
 -- @once
 -- @print Including sheets.core.Style

local function format_field_name( name )
	if not name:find "%." then
		return name .. ".default"
	end
	return name
end

local function get_default_field_name( name )
	return name:gsub( "%..-$", "", 1 ) .. ".default"
end

local template = {}

class "Style" {
	fields = {};
	object = nil;
}

function Style.add_to_template( cls, fields )
	if not class.is_class( cls ) then throw( IncorrectParameterException( "expected Class class, got " .. class.type( cls ), 2 ) ) end
	if type( fields ) ~= "table" then throw( IncorrectParameterException( "expected table fields, got " .. class.type( fields ), 2 ) ) end

	template[cls] = template[cls] or {}
	for k, v in pairs( fields ) do
		template[cls][format_field_name( k )] = v
	end
end

function Style:Style( object )
	if not class.is_instance( object ) then throw( IncorrectConstructorException( "Style expects Instance object when created, got " .. class.type( object ), 3 ) ) end

	template[object.class] = template[object.class] or {}
	self.fields = {}
	self.object = object
end

function Style:clone( object )
	if not class.is_instance( object ) then throw( IncorrectInitialiserException( "expected Instance object, got " .. class.type( object ), 2 ) ) end

	local s = Style( object or self.object )
	for k, v in pairs( self.fields ) do
		s.fields[k] = v
	end
	return s
end

function Style:set( field, value )
	parameters.check( 1, "field", "string", field )

	self.fields[format_field_name( field )] = value
	self.object:set_changed()
	return self
end

function Style:get( field )
	parameters.check( 1, "field", "string", field )

	field = format_field_name( field )
	local default = get_default_field_name( field )
	if self.fields[field] ~= nil then
		return self.fields[field]
	elseif self.fields[default] ~= nil then
		return self.fields[default]
	elseif template[self.object.class][field] ~= nil then
		return template[self.object.class][field]
	end
	return template[self.object.class][default]
end
