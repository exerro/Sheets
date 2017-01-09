
 -- @once
 -- @print Including sheets.graphics.Canvas

 -- @require graphics.area as area

local function range( a, b, c, d )
	local x = a > c and a or c
	local y = ( a + b < c + d and a + b or c + d ) - x
	return x, y
end

local insert, remove = table.insert, table.remove
local min, max = math.min, math.max
local floor = math.floor

class "Canvas" {
	width = 0;
	height = 0;

	colour = WHITE;

	buffer = {};
}

function Canvas:Canvas( width, height )
	width = width or 0
	height = height or 0

	if type( width ) ~= "number" then return error( "element attribute #1 'width' not a number (" .. class.type( width ) .. ")", 2 ) end
	if type( height ) ~= "number" then return error( "element attribute #2 'height' not a number (" .. class.type( height ) .. ")", 2 ) end

	self.width = width
	self.height = height
	self.buffer = {}

	local px = BLANK_PIXEL
	for i = 1, width * height do
		self.buffer[i] = px
	end
end

function Canvas:set_width( width )
	if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end

	width = math.floor( width )
	local height, buffer = self.height, self.buffer
	local s_width = self.width
	local px = { self.colour, WHITE, " " }

	while s_width < width do
		for i = 1, height do
			insert( buffer, ( s_width + 1 ) * i, px )
		end
		s_width = s_width + 1
	end

	while s_width > width do
		for i = height, 1, -1 do
			remove( buffer, s_width * i )
		end
		s_width = s_width - 1
	end

	self.width = s_width
end

function Canvas:set_height( height )
	if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end

	height = math.floor( height )
	local width, buffer = self.width, self.buffer
	local s_height = self.height
	local px = { self.colour, WHITE, " " }

	while s_height < height do
		for i = 1, width do
			buffer[#buffer + 1] = px
		end
		s_height = s_height + 1
	end

	while s_height > height do
		for i = 1, width do
			buffer[#buffer] = nil
		end
		s_height = s_height - 1
	end

	self.height = s_height
end

 -- @if GRAPHICS_NO_TEXT
 	function Canvas:get_pixel( x, y )
 		local s_width = self.width
 		if x >= 0 and x < s_width and y >= 0 and y < self.height then
 			return self.buffer[y * s_width + x + 1]
 		end
 	end
 -- @else
 	function Canvas:get_pixel( x, y )
 		local s_width = self.width
 		if x >= 0 and x < s_width and y >= 0 and y < self.height then
 			local px = self.buffer[y * s_width + x + 1]
 			return px[1], px[2], px[3]
 		end
 	end
 -- @endif

function Canvas:map_colour( coords, colour )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end

	local px = { colour, WHITE, " " }
	local pxls = self.buffer
	for i = 1, #coords do
		pxls[coords[i]] = px
	end
end

function Canvas:map_colours( coords, colours )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colours ) ~= "table" then return error( "expected table colours, got " .. class.type( colours ) ) end

	local pxls = self.buffer
	local l = #colours
	for i = 1, #coords do
		pxls[coords[i]] = { colours[( i - 1 ) % l + 1], WHITE, " " }
	end
end

 --@ ifn GRAPHICS_NO_TEXT
	function Canvas:map_pixel( coords, pixel )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixel ) ~= "table" then return error( "expected table pixel, got " .. class.type( pixel ) ) end
		local pxls = self.buffer
		for i = 1, #coords do
			pxls[coords[i]] = pixel
		end
	end

	function Canvas:map_pixels( coords, pixels )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixels ) ~= "table" then return error( "expected table pixels, got " .. class.type( pixels ) ) end
		local pxls = self.buffer
		for i = 1, #coords do
			pxls[coords[i]] = pixels[i]
		end
	end
 -- @endif

 --@ if GRAPHICS_NO_TEXT
 	function Canvas:map_shader( coords, shader )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( shader ) ~= "function" then return error( "expected function shader, got " .. class.type( shader ) ) end
		local pxls = self.buffer
		local width = self.width
		local changed = {}

		for i = 1, #coords do
			local p = coords[i]
			local rem = ( p - 1 ) % width
			local colour = shader( pxls[p], rem, ( p - 1 - rem ) / width )

			changed[i] = colour
		end

		for i = 1, #coords do
			local c = changed[i]
			if c then
				pxls[coords[i]] = c
			end
		end
 	end
 -- @else
	function Canvas:map_shader( coords, shader )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( shader ) ~= "function" then return error( "expected function shader, got " .. class.type( shader ) ) end

		local pxls = self.buffer
		local width = self.width
		local changed = {}

		for i = 1, #coords do
			local p = coords[i]
			local px = pxls[p]
			local rem = ( p - 1 ) % width
			local bc, tc, char = shader( px[1], px[2], px[3], rem, ( p - 1 - rem ) / width )

			changed[i] = ( bc or tc or char ) and { bc or px[1], tc or px[2], char or px[3] }
		end

		for i = 1, #coords do
			local c = changed[i]
			if c then
				pxls[coords[i]] = c
			end
		end
	end
 -- @endif

function Canvas:shift( area, x, y, blank )
	local s_width = self.width
	if type( area ) == "number" then
		x, y, blank = area, x, y
		area = {}
		for i = 1, s_width * self.height do
			area[i] = i
		end
	end
	local diff = y * s_width + x
	local buffer = self.buffer
	for i = 1, #area do
		buffer[i] = buffer[i + diff] or blank
	end
end

function Canvas:draw_colour( coords, colour )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end

	if colour == TRANSPARENT then return end
	local px = { colour, WHITE, " " }
	local buffer = self.buffer
	for i = 1, #coords do
		buffer[coords[i]] = px
	end
end

function Canvas:draw_colours( coords, colours )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colours ) ~= "table" then return error( "expected table colours, got " .. class.type( colours ) ) end

	local l = #colours
	local pxls = self.buffer
	for i = 1, #coords do
		if colours[i] ~= TRANSPARENT then
			pxls[coords[i]] = { colours[( i - 1 ) % l + 1], WHITE, " " }
		end
	end
end

 --@ ifn GRAPHICS_NO_TEXT
	function Canvas:draw_pixel( coords, pixel )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixel ) ~= "table" then return error( "expected table pixel, got " .. class.type( pixel ) ) end

		local pxls = self.buffer
		if pixel[1] == TRANSPARENT and ( pixel[2] == TRANSPARENT or pixel[3] == "" ) then
			return -- not gonna draw anything
		elseif pixel[1] == TRANSPARENT or pixel[2] == TRANSPARENT or pixel[3] == "" then
			local bc, tc, char = pixel[1], pixel[2], pixel[3]
			for i = 1, #coords do
				local c = coords[i]
				local cpx, cbc, ctc, cchar
				if bc == TRANSPARENT then
					cpx = pxls[c]
					cbc = cpx[1]
				end
				if tc == TRANSPARENT or char == "" then
					cpx = cpx or pxls[c]
					ctc = cpx[2]
					cchar = cpx[3]
				end
				pxls[c] = { cbc or bc, ctc or tc, cchar or char }
			end
		else
			for i = 1, #coords do
				pxls[coords[i]] = pixel
			end
		end
	end

	function Canvas:draw_pixels( coords, pixels )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixels ) ~= "table" then return error( "expected table pixels, got " .. class.type( pixels ) ) end

		local l = #pixels
		local pxls = self.buffer
		local mod_needed = l < #coords
		for i = 1, #coords do
			local px = mod_needed and pixels[( i - 1 ) % l + 1] or pixels[i]
			local bc, tc, char = px[1], px[2], px[3]
			local cpx
			if bc == TRANSPARENT then
				cpx = pxls[coords[i]]
				bc = cpx[1]
			end
			if tc == TRANSPARENT or char == "" then
				cpx = cpx or pxls[coords[i]]
				tc = cpx[2]
				char = cpx[3]
			end
			pxls[coords[i]] = { bc, tc, char }
		end
	end
-- @endif

function Canvas:clear( colour )
	if colour and type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end

	local px = { colour or self.colour, colour and WHITE or TRANSPARENT, " " }
	for i = 1, self.width * self.height do
		self.buffer[i] = px
	end
end

function Canvas:clone( _class )
	if _class and not class.is_class( _class ) then return error( "expected Class class, got " .. class.type( _class ) ) end

	local new = ( _class or self.class )( self.width, self.height )
	new.buffer = self.buffer
	return new
end

function Canvas:copy( _class )
	if _class and not class.is_class( _class ) then return error( "expected Class class, got " .. class.type( _class ) ) end

	local new = ( _class or self.class )( self.width, self.height )
	local b1, b2 = new.buffer, self.buffer
	for i = 1, #b2 do
		b1[i] = b2[i]
	end
	return new
end

function Canvas:draw_to( canvas, offsetX, offsetY )
	offsetX, offsetY = offsetX or 0, offsetY or 0

	if not class.type_of( canvas, Canvas ) then return error( "expected Canvas canvas, got " .. class.type( canvas ) ) end
	if type( offsetX ) ~= "number" then return error( "expected number offsetX, got " .. class.type( offsetX ) ) end
	if type( offsetY ) ~= "number" then return error( "expected number offsetY, got " .. class.type( offsetY ) ) end

	local width, height = self.width, self.height
	local other_width, other_height = canvas.width, canvas.height

	local to_draw_coords = {}
	local to_draw_pixels = {}
	local pc = 1
	local buffer = self.buffer

	local a, b = range( 0, other_width, offsetX, width )

	a = a - offsetX + 1
	b = a + b - 1

	for y = 0, height - 1 do
		local my = y + offsetY
		if my >= 0 and my < other_height then
			local coord = y * width
			local other_coord = my * other_width + offsetX
			for i = a, b do
				if buffer[coord + i] then
					to_draw_pixels[pc] = buffer[coord + i]
					to_draw_coords[pc] = other_coord + i
					pc = pc + 1
				end
			end
		end
	end

	-- @if GRAPHICS_NO_TEXT
		canvas:draw_colours( to_draw_coords, to_draw_pixels )
	-- @else
		canvas:draw_pixels( to_draw_coords, to_draw_pixels )
	-- @endif
end

function Canvas:get_area( mode, a, b, c, d )
	area.set_dimensions( self.width, self.height )
	if mode == GRAPHICS_AREA_FILL then
		return area.fill()
	elseif mode == GRAPHICS_AREA_BOX then
		if type( a ) ~= "number" then return error( "expected number x, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y, got " .. class.type( b ) ) end
		if type( c ) ~= "number" then return error( "expected number width, got " .. class.type( c ) ) end
		if type( d ) ~= "number" then return error( "expected number height, got " .. class.type( d ) ) end

		return area.box( a, b, c, d )
	elseif mode == GRAPHICS_AREA_POINT then
		if type( a ) ~= "number" then return error( "expected number x, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y, got " .. class.type( b ) ) end

		return area.point( a, b )
	elseif mode == GRAPHICS_AREA_HLINE then
		if type( a ) ~= "number" then return error( "expected number x, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y, got " .. class.type( b ) ) end
		if type( c ) ~= "number" then return error( "expected number width, got " .. class.type( c ) ) end

		return area.h_line( a, b, c )
	elseif mode == GRAPHICS_AREA_VLINE then
		if type( a ) ~= "number" then return error( "expected number x, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y, got " .. class.type( b ) ) end
		if type( c ) ~= "number" then return error( "expected number height, got " .. class.type( c ) ) end

		return area.v_line( a, b, c )
	elseif mode == GRAPHICS_AREA_LINE then
		if type( a ) ~= "number" then return error( "expected number x1, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y1, got " .. class.type( b ) ) end
		if type( c ) ~= "number" then return error( "expected number x2, got " .. class.type( c ) ) end
		if type( d ) ~= "number" then return error( "expected number y2, got " .. class.type( d ) ) end

		return area.line( a, b, c, d )
	elseif mode == GRAPHICS_AREA_CIRCLE then
		if type( a ) ~= "number" then return error( "expected number x, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y, got " .. class.type( b ) ) end
		if type( c ) ~= "number" then return error( "expected number radius, got " .. class.type( c ) ) end

		return area.circle( a, b, c )
	elseif mode == GRAPHICS_AREA_CCIRCLE then
		if type( a ) ~= "number" then return error( "expected number x, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y, got " .. class.type( b ) ) end
		if type( c ) ~= "number" then return error( "expected number radius, got " .. class.type( c ) ) end

		return area.corrected_circle( a, b, c )
	else
		return error( "unexpected mode: " .. tostring( mode ) )
	end
end
