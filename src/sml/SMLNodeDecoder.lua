
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.sml.SMLNodeDecoder'
 -- @endif

 -- @print Including sheets.sml.SMLNodeDecoder

class "SMLNodeDecoder" {
	name = "node";
	isBodyAllowed = false;
	isBodyNecessary = false;
}

function SMLNodeDecoder:decode( node )

	if node.body and not self.isBodyAllowed then
		return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: body not allowed for node '" .. self.name .. "'", 0 )
	elseif not node.body and self.isBodyNecessary then
		return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: body required for node '" .. self.name .. "'", 0 )
	end

	local element = self:init()

	for k, v in pairs( node.attributes ) do
		if self["attribute_" .. k] then
			local ok, data = pcall( self["attribute_" .. k], element, v, node )
			if not ok then
				return false, data
			end
		else
			return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: invalid attribute '" .. k .. "' for node '" .. self.name .. "'", 0 )
		end
	end

	if node.body then
		local ok, data = pcall( self.decodeBody, element, node.body )
		if not ok then
			return false, data
		end
	end

	return element
end

function SMLNodeDecoder:init( node )

end

function SMLNodeDecoder:decodeBody( body )

end
