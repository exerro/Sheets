
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
	 -- @if SHEETS_TYPE_CHECK
		if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
		if type( field ) ~= "string" then return error( "expected string field, got " .. class.type( field ) ) end
		if type( state ) ~= "string" then return error( "expected string state, got " .. class.type( state ) ) end
	 -- @endif
	self.elements[cls] = self.elements[cls] or {}
	self.elements[cls][field] = self.elements[cls][field] or {}
	self.elements[cls][field][state] = value
end

function Theme:getField( cls, field, state )
	 -- @if SHEETS_TYPE_CHECK
		if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
		if type( field ) ~= "string" then return error( "expected string field, got " .. class.type( field ) ) end
		if type( state ) ~= "string" then return error( "expected string state, got " .. class.type( state ) ) end
	 -- @endif
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

local decoder = SMLNodeDecoder "theme"

decoder.isBodyAllowed = true
decoder.isBodyNecessary = true

function decoder:init()
	return Theme()
end

function decoder:attribute_name( name )
	SMLDocument.current():setTheme( name, self )
end

function decoder:decodeBody( body )
	local doc = SMLDocument.current()
	for i = 1, #body do
		local element = doc:getElement( body[i].nodetype )
		if element then
			local fields = body[i].body
			if fields then
				for i = 1, #fields do
					if fields[i].body then
						error( "[" .. fields[i].position.line .. ", " .. fields[i].position.character .. "] : field '" .. fields[i].nodetype .. "' has body", 0 )
					end
					for k, v in pairs( fields[i].attributes ) do
						if doc:getVariable( v ) ~= nil then
							v = doc:getVariable( v )
						end
						self:setField( element, fields[i].nodetype, k, v )
					end
				end
			else
				error( "[" .. body[i].position.line .. ", " .. body[i].position.character .. "] : element has no body for fields", 0 )
			end
		else
			error( "[" .. body[i].position.line .. ", " .. body[i].position.character .. "] : unknown element '" .. body[i].nodetype .. "'", 0 )
		end
	end
end

SMLDocument:setDecoder( "theme", decoder )
