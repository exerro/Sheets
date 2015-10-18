
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
	template[class][field] = states
end

function Theme:Theme()
	self.elements = setmetatable( {}, { __index = template } )
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

SMLEnvironment:setDecoder( "theme", function( node )
	local env = SMLEnvironment.current()
	local theme = Theme()
	if not node.body then
		error( "[" .. node.position.line .. ", " .. node.position.character .. "] : theme has no body", 0 )
	end
	if type( node:get "name" ) == "string" then
		env:setTheme( node:get "name", theme )
	end
	for i = 1, #node.body do
		local element = env:getElement( node.body[i].nodetype )
		if element then
			local fields = node.body[i].body
			if fields then
				for i = 1, #fields do
					if fields[i].body then
						error( "[" .. fields[i].position.line .. ", " .. fields[i].position.character .. "] : field '" .. fields[i].nodetype .. "' has body", 0 )
					end
					for k, v in pairs( fields[i].attributes ) do
						if env:getVariable( v ) ~= nil then
							v = env:getVariable( v )
						end
						theme:setField( element, fields[i].nodetype, k, v )
					end
				end
			else
				error( "[" .. node.body[i].position.line .. ", " .. node.body[i].position.character .. "] : element has no body for fields", 0 )
			end
		else
			error( "[" .. node.body[i].position.line .. ", " .. node.body[i].position.character .. "] : unknown element '" .. node.body[i].nodetype .. "'", 0 )
		end
	end
	return theme
end )
