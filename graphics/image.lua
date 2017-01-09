
 -- @once
 -- @print Including sheets.graphics.image

local hex_lookup = {}
for i = 0, 15 do
	hex_lookup[2 ^ i] = ("%x"):format( i )
	hex_lookup[("%x"):format( i )] = 2 ^ i
	hex_lookup[("%X"):format( i )] = 2 ^ i
end

image = {}

function image.decode_paintutils( str, canvas )
	local lines = {}
	for line in str:gmatch "[^\n]+" do
		local decoded_line = {}
		for i = 1, #line do
			-- @if GRAPHICS_NO_TEXT
				decoded_line[i] = hex_lookup[ line:sub( i, i ) ] or 0
			-- @else
				decoded_line[i] = { hex_lookup[ line:sub( i, i ) ] or 0, 1, " " }
			-- @endif
		end
		lines[#lines + 1] = decoded_line
	end
	return lines
end

function image.encode_paintutils( canvas )

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
		canvas:map_colours( coords, pixels )
	-- @else
		canvas:map_pixels( coords, pixels )
	-- @endif
end
