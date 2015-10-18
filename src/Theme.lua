
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
	template[class] = template[class] or {}
	template[class][field] = states
end

function Theme:Theme()
	self.elements = setmetatable( {}, { __index = template } )
end

function Theme:setField( class, field, state, value )
	self.elements[class] = self.elements[class] or {}
	self.elements[class][field] = self.elements[class][field] or {}
	self.elements[class][field][state] = value
end

function Theme:getField( class, field, state )
	if self.elements[class] then
		if self.elements[class][field] then
			if self.elements[class][field][state] then
				return self.elements[class][field][state]
			end
		end
	end
	if template[class] then
		if template[class][field] then
			if template[class][field][state] then
				return template[class][field][state]
			end
		end
	end
	if self.elements[class] then
		if self.elements[class][field] then
			if self.elements[class][field].default then
				return self.elements[class][field].default
			end
		end
	end
end
