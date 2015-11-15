
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.graphics.image'
 -- @endif

 -- @print Including sheets.graphics.image

local hexLookup = {}
for i = 0, 15 do
	hexLookup[2 ^ i] = ("%x"):format( i )
	hexLookup[("%x"):format( i )] = 2 ^ i
	hexLookup[("%X"):format( i )] = 2 ^ i
end

image = {}

function image.decodePaintutils( str, canvas )
	local lines = {}
	for line in str:gmatch "[^\n]+" do
		local decodedLine = {}
		for i = 1, #line do
			-- @if GRAPHICS_NO_TEXT
				decodedLine[i] = hexLookup[ line:sub( i, i ) ] or 0
			-- @else
				decodedLine[i] = { hexLookup[ line:sub( i, i ) ] or 0, 1, " " }
			-- @endif
		end
		lines[#lines + 1] = decodedLine
	end
	return lines
end

function image.encodePaintutils( canvas )

end

function image.apply( map, canvas )
	local pixels, coords = {}, {}
	local n = 1

	for y = 0, math.min( #map, canvas.height ) - 1 do
		local pos = y * canvas.width
		for x = 1, math.min( #map[y + 1], canvas.width ) do
			pixels[n] = map[y + 1][x]
			coords[n] = pos + x
			n = n + 1
		end
	end

	-- @if GRAPHICS_NO_TEXT
		canvas:mapColours( coords, pixels )
	-- @else
		canvas:mapPixels( coords, pixels )
	-- @endif
end
