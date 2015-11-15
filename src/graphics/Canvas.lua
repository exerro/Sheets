
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.graphics.Canvas'
 -- @endif

 -- @print Including sheets.graphics.Canvas

 -- @require sheets.graphics.area as area

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

	pixels = {};
}

function Canvas:Canvas( width, height )
	width = width or 0
	height = height or 0
	
	if type( width ) ~= "number" then return error( "element attribute #1 'width' not a number (" .. class.type( width ) .. ")", 2 ) end
	if type( height ) ~= "number" then return error( "element attribute #2 'height' not a number (" .. class.type( height ) .. ")", 2 ) end

	self.width = width
	self.height = height
	self.pixels = {}

	local px = BLANK_PIXEL
	for i = 1, width * height do
		self.pixels[i] = px
	end
end

function Canvas:setWidth( width )
	if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end

	width = math.floor( width )
	local height, pixels = self.height, self.pixels
	local sWidth = self.width
	local px = { self.colour, WHITE, " " }

	while sWidth < width do
		for i = 1, height do
			insert( pixels, ( sWidth + 1 ) * i, px )
		end
		sWidth = sWidth + 1
	end

	while sWidth > width do
		for i = height, 1, -1 do
			remove( pixels, sWidth * i )
		end
		sWidth = sWidth - 1
	end

	self.width = sWidth
end

function Canvas:setHeight( height )
	if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end

	height = math.floor( height )
	local width, pixels = self.width, self.pixels
	local sHeight = self.height
	local px = { self.colour, WHITE, " " }
	
	while sHeight < height do
		for i = 1, width do
			pixels[#pixels + 1] = px
		end
		sHeight = sHeight + 1
	end

	while sHeight > height do
		for i = 1, width do
			pixels[#pixels] = nil
		end
		sHeight = sHeight - 1
	end

	self.height = sHeight
end

 -- @if GRAPHICS_NO_TEXT
 	function Canvas:getPixel( x, y )
 		local sWidth = self.width
 		if x >= 0 and x < sWidth and y >= 0 and y < self.height then
 			return self.pixels[y * sWidth + x + 1]
 		end
 	end
 -- @else
 	function Canvas:getPixel( x, y )
 		local sWidth = self.width
 		if x >= 0 and x < sWidth and y >= 0 and y < self.height then
 			local px = self.pixels[y * sWidth + x + 1]
 			return px[1], px[2], px[3]
 		end
 	end
 -- @endif

function Canvas:mapColour( coords, colour )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end

	local px = { colour, WHITE, " " }
	local pxls = self.pixels
	for i = 1, #coords do
		pxls[coords[i]] = px
	end
end

function Canvas:mapColours( coords, colours )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colours ) ~= "table" then return error( "expected table colours, got " .. class.type( colours ) ) end

	local pxls = self.pixels
	local l = #colours
	for i = 1, #coords do
		pxls[coords[i]] = { colours[( i - 1 ) % l + 1], WHITE, " " }
	end
end

 --@ ifn GRAPHICS_NO_TEXT
	function Canvas:mapPixel( coords, pixel )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixel ) ~= "table" then return error( "expected table pixel, got " .. class.type( pixel ) ) end
		local pxls = self.pixels
		for i = 1, #coords do
			pxls[coords[i]] = pixel
		end
	end

	function Canvas:mapPixels( coords, pixels )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixels ) ~= "table" then return error( "expected table pixels, got " .. class.type( pixels ) ) end
		local pxls = self.pixels
		for i = 1, #coords do
			pxls[coords[i]] = pixels[i]
		end
	end
 -- @endif

 --@ if GRAPHICS_NO_TEXT
 	function Canvas:mapShader( coords, shader )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( shader ) ~= "function" then return error( "expected function shader, got " .. class.type( shader ) ) end
		local pxls = self.pixels
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
	function Canvas:mapShader( coords, shader )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( shader ) ~= "function" then return error( "expected function shader, got " .. class.type( shader ) ) end

		local pxls = self.pixels
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
	local sWidth = self.width
	if type( area ) == "number" then
		x, y, blank = area, x, y
		area = {}
		for i = 1, sWidth * self.height do
			area[i] = i
		end
	end
	local diff = y * sWidth + x
	local pixels = self.pixels
	for i = 1, #area do
		pixels[i] = pixels[i + diff] or blank
	end
end

function Canvas:drawColour( coords, colour )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end

	if colour == TRANSPARENT then return end
	local px = { colour, WHITE, " " }
	local pixels = self.pixels
	for i = 1, #coords do
		pixels[coords[i]] = px
	end
end

function Canvas:drawColours( coords, colours )
	if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
	if type( colours ) ~= "table" then return error( "expected table colours, got " .. class.type( colours ) ) end

	local l = #colours
	local pxls = self.pixels
	for i = 1, #coords do
		if colours[i] ~= TRANSPARENT then
			pxls[coords[i]] = { colours[( i - 1 ) % l + 1], WHITE, " " }
		end
	end
end

 --@ ifn GRAPHICS_NO_TEXT
	function Canvas:drawPixel( coords, pixel )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixel ) ~= "table" then return error( "expected table pixel, got " .. class.type( pixel ) ) end

		local pxls = self.pixels
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

	function Canvas:drawPixels( coords, pixels )
		if type( coords ) ~= "table" then return error( "expected table coords, got " .. class.type( coords ) ) end
		if type( pixels ) ~= "table" then return error( "expected table pixels, got " .. class.type( pixels ) ) end

		local l = #pixels
		local pxls = self.pixels
		local modNeeded = l < #coords
		for i = 1, #coords do
			local px = modNeeded and pixels[( i - 1 ) % l + 1] or pixels[i]
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
		self.pixels[i] = px
	end
end

function Canvas:clone( _class )
	if _class and not class.isClass( _class ) then return error( "expected Class class, got " .. class.type( _class ) ) end

	local new = ( _class or self.class )( self.width, self.height )
	new.pixels = self.pixels
	return new
end

function Canvas:copy( _class )
	if _class and not class.isClass( _class ) then return error( "expected Class class, got " .. class.type( _class ) ) end

	local new = ( _class or self.class )( self.width, self.height )
	local b1, b2 = new.pixels, self.pixels
	for i = 1, #b2 do
		b1[i] = b2[i]
	end
	return new
end

function Canvas:drawTo( canvas, offsetX, offsetY )
	offsetX, offsetY = offsetX or 0, offsetY or 0

	if not class.typeOf( canvas, Canvas ) then return error( "expected Canvas canvas, got " .. class.type( canvas ) ) end
	if type( offsetX ) ~= "number" then return error( "expected number offsetX, got " .. class.type( offsetX ) ) end
	if type( offsetY ) ~= "number" then return error( "expected number offsetY, got " .. class.type( offsetY ) ) end

	local width, height = self.width, self.height
	local otherWidth, otherHeight = canvas.width, canvas.height

	local toDrawCoords = {}
	local toDrawPixels = {}
	local pc = 1
	local pixels = self.pixels

	local a, b = range( 0, otherWidth, offsetX, width )

	a = a - offsetX + 1
	b = a + b - 1

	for y = 0, height - 1 do
		local my = y + offsetY
		if my >= 0 and my < otherHeight then
			local coord = y * width
			local otherCoord = my * otherWidth + offsetX
			for i = a, b do
				if pixels[coord + i] then
					toDrawPixels[pc] = pixels[coord + i]
					toDrawCoords[pc] = otherCoord + i
					pc = pc + 1
				end
			end
		end
	end

	-- @if GRAPHICS_NO_TEXT
		canvas:drawColours( toDrawCoords, toDrawPixels )
	-- @else
		canvas:drawPixels( toDrawCoords, toDrawPixels )
	-- @endif
end

function Canvas:getArea( mode, a, b, c, d )
	area.setDimensions( self.width, self.height )
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

		return area.hLine( a, b, c )
	elseif mode == GRAPHICS_AREA_VLINE then
		if type( a ) ~= "number" then return error( "expected number x, got " .. class.type( a ) ) end
		if type( b ) ~= "number" then return error( "expected number y, got " .. class.type( b ) ) end
		if type( c ) ~= "number" then return error( "expected number height, got " .. class.type( c ) ) end

		return area.vLine( a, b, c )
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

		return area.correctedCircle( a, b, c )
	else
		return error( "unexpected mode: " .. tostring( mode ) )
	end
end
