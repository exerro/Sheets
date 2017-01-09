
 -- @once
 -- @print Including sheets.graphics.area

-- @ifn CIRCLE_CORRECTION
local CIRCLE_CORRECTION = 1.5
-- @endif

local function range( a, b, c, d )
	local x = a > c and a or c
	local y = ( a + b < c + d and a + b or c + d ) - x
	return x, y
end

local area__join, area__sub, area__intersect, area__tostring

local function areamt( t )
	return setmetatable( t, { __add = area__join, __sub = area__sub, __mod = area__intersect, __tostring = area__tostring } )
end

function area__join( a, b )
	local i1, i2, c = 1, 1, 0
	local t = {}
	while a[i1] or b[i2] do
		if a[i1] and ( not b[i2] or a[i1] <= b[i2] ) then
			if t[c] ~= a[i1] then
				c = c + 1
				t[c] = a[i1]
			end
			i1 = i1 + 1
		elseif b[i2] and ( not a[i1] or a[i1] > b[i2] ) then
			if t[c] ~= b[i2] then
				c = c + 1
				t[c] = b[i2]
			end
			i2 = i2 + 1
		end
	end
	return areamt( t )
end

function area__sub( a, b )
	local i1, i2, c = 1, 1, 1
	local t = {}
	while a[i1] do
		while b[i2] and b[i2] < a[i1] do
			i2 = i2 + 1
		end
		if a[i1] ~= b[i2] then
			t[c] = a[i1]
			c = c + 1
		end
		i1 = i1 + 1
	end
	return areamt( t )
end

function area__intersect( a, b )
	local i1, i2, c = 1, 1, 1
	local t = {}
	while a[i1] do
		while b[i2] and b[i2] < a[i1] do
			i2 = i2 + 1
		end
		if a[i1] == b[i2] then
			t[c] = a[i1]
			c = c + 1
		end
		i1 = i1 + 1
	end
	return areamt( t )
end

function area__tostring( a )
	return "Area of " .. #a .. " coordinates"
end

local width, height = term.getSize()

local area = {}

function area.set_dimensions( w, h )
	width, height = w, h
end

function area.new( t )
	return areamt( t )
end

function area.blank()
	return areamt {}
end

function area.fill()
	local t = {}
	for i = 1, width * height do
		t[i] = i
	end
	return areamt( t )
end

function area.point( x, y )
	if x >= 0 and x < width and y >= 0 and y < height then
		return areamt { y * width + x + 1 }
	end
	return areamt {}
end

function area.box( x, y, w, h )
	x, w = range( 0, width, x, w )
	y, h = range( 0, height, y, h )

	local pos = y * width + x
	local t, i = {}, 1

	for _ = 1, h do
		for x = 1, w do
			t[i] = pos + x
			i = i + 1
		end
		pos = pos + width
	end

	return areamt( t )
end

function area.circle( x, y, radius )
	local radius2 = radius * radius
	local t = {}
	local i = 1

	for yy = math.floor( y - radius ), math.ceil( y + radius ) do
		if yy > 0 and yy < height then
			local diff = y - yy
			local xdiff = ( radius2 - diff * diff ) ^ .5

			local ypos = yy * width + 1
			local sx = math.floor( x - xdiff + .5 )
			local a, b = range( 0, width, sx, math.ceil( x + xdiff - .5 ) - sx + 1 )
			for xx = a, a + b - 1 do
				t[i] = ypos + xx
				i = i + 1
			end
		end
	end

	return areamt( t )
end

function area.corrected_circle( x, y, radius )
	local radius2 = radius * radius
	local t = {}
	local i = 1

	for yy = math.floor( y - radius + 1 ), math.ceil( y + radius - 1 ) do
		if yy >= 0 and yy < height then
			local diff = y - yy
			local xdiff = ( radius2 - diff * diff ) ^ .5 * CIRCLE_CORRECTION

			local ypos = yy * width + 1
			local sx = math.floor( x - xdiff + .5 )
			local a, b = range( 0, width, sx, math.ceil( x + xdiff - .5 ) - sx + 1 )
			for xx = a, a + b - 1 do
				t[i] = ypos + xx
				i = i + 1
			end
		end
	end

	return areamt( t )
end

function area.h_line( x, y, w )
	if y >= 0 and y < height then
		x, w = range( 0, width, x, w )
		local pos = y * width + x
		local t = {}
		for i = 1, w do
			t[i] = pos + i
		end
		return areamt( t )
	end
	return areamt {}
end

function area.v_line( x, y, h )
	if x >= 0 and x < width then
		y, h = range( 0, height, y, h )
		local pos = y * width + x + 1
		local t = {}
		for i = 1, h do
			t[i] = pos
			pos = pos + width
		end
		return areamt( t )
	end
	return areamt {}
end

function area.line( x1, y1, x2, y2 )
	if x1 > x2 then
		x1, x2 = x2, x1
		y1, y2 = y2, y1
	end

	local dx, dy = x2 - x1, y2 - y1

	if dx == 0 then
		if dy == 0 then
			return new_point_area( x1, y1, width, height )
		end
		return new_v_line_area( x1, y1, dy, width, height )
	elseif dy == 0 then
		return new_h_line_area( x1, y1, dx, width, height )
	end

	local points = {}

	if x1 >= 0 and x1 < width and y1 >= 0 and y1 < height then
		points[1] = math.floor( y1 + .5 ) * width + math.floor( x1 + .5 ) + 1
		if x2 >= 0 and x2 < width and y2 >= 0 and y2 < height then
			points[2] = math.floor( y2 + .5 ) * width + math.floor( x2 + .5 ) + 1
		end
	elseif x2 >= 0 and x2 < width and y2 >= 0 and y2 < height then
		points[1] = math.floor( y2 + .5 ) * width + math.floor( x2 + .5 ) + 1
	end

	local m = dy / dx
	local c = y1 - m * x1
	local step = math.min( 1 / math.abs( m ), 1 )

	local i = #points + 1

	for x = math.max( x1, 0 ), math.min( x2, width - 1 ), step do
		local y = math.floor( m * x + c + .5 )
		if y > 0 and y < height then
			points[i] = y * width + math.floor( x + .5 ) + 1
			i = i + 1
		end
	end

	return areamt( points )
end

return area
