
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Theme'
 -- @endif

 -- @print Including sheets.Theme

local template = {}

class "Theme" {
	elements = {};
}

function Theme.addToTemplate( class, field, states )
	if not class.isClass( class ) then return error( "expected Class class, got " .. class.type( class ) ) end
	if type( field ) ~= "string" then return error( "expected string field, got " .. class.type( field ) ) end
	if type( states ) ~= "table" then return error( "expected table states, got " .. class.type( states ) ) end
	template[class] = template[class] or {}
	template[class][field] = template[class][field] or {}
	for k, v in pairs( states ) do
		template[class][field][k] = v
	end
end

function Theme:Theme()
	self.elements = {}
end

function Theme:setField( cls, field, state, value )
	if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
	if type( field ) ~= "string" then return error( "expected string field, got " .. class.type( field ) ) end
	if type( state ) ~= "string" then return error( "expected string state, got " .. class.type( state ) ) end
	self.elements[cls] = self.elements[cls] or {}
	self.elements[cls][field] = self.elements[cls][field] or {}
	self.elements[cls][field][state] = value
end

function Theme:getField( cls, field, state )
	if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
	if type( field ) ~= "string" then return error( "expected string field, got " .. class.type( field ) ) end
	if type( state ) ~= "string" then return error( "expected string state, got " .. class.type( state ) ) end
	if self.elements[cls] then
		if self.elements[cls][field] then
			if self.elements[cls][field][state] then
				return self.elements[cls][field][state]
			end
		end
	end
	if template[cls] then
		if template[cls][field] then
			if template[cls][field][state] then
				return template[cls][field][state]
			end
		end
	end
	if self.elements[cls] then
		if self.elements[cls][field] then
			if self.elements[cls][field].default then
				return self.elements[cls][field].default
			end
		end
	end
end
