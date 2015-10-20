
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.sml.SMLNode'
 -- @endif

 -- @print Including sheets.sml.SMLNode

class "SMLNode" {
	nodetype = "blank";
	attributes = {};
	body = nil;
	position = { line = 0, character = 0 };
}

function SMLNode:SMLNode( type, attributes, body, position )
	self.nodetype = type
	self.attributes = attributes
	self.body = body
	self.position = position
end

function SMLNode:set( attribute, value )
	for i = 1, #self.attributes do
		if self.attributes[i][1] == attribute then
			self.attributes[i][2] = value
		end
	end
end

function SMLNode:get( attribute )
	for i = 1, #self.attributes do
		if self.attributes[i][1] == attribute then
			return self.attributes[i][2]
		end
	end
end

function SMLNode:tostring( indent )
	local whitespace = ("  "):rep( indent or 0 )
	local a, b = "", {}

	for k, v in pairs( self.attributes ) do
		if v == true then
			a = a .. " " .. k
		else
			pcall( function()
				a = a .. " " .. k .. "=" .. textutils.serialize( v )
			end )
		end
	end

	if self.body then
		for i = 1, #self.body do
			b[i] = whitespace .. "  " .. self.body[i]:tostring( ( indent or 0 ) + 1 )
		end

		return "<" .. self.nodetype .. a .. ">\n\n" .. table.concat( b, "\n" ) .. "\n\n" .. whitespace .. "</" .. self.nodetype .. ">"
	else
		return "<" .. self.nodetype .. a .. "/>"
	end
end
