
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IChildDecoder'
 -- @endif

 -- @print Including sheets.interfaces.IChildDecoder

IChildDecoder = {}

function IChildDecoder:decodeChildren( body )
	local document = SMLDocument.current()
	local c = {}

	for i = 1, #body do
		local object, err = document:loadSMLNode( body[i], self )
		if object then
			c[i] = object
		else
			return error( err, 0 )
		end
	end

	return c
end
