
 -- @once
 -- @print Including sheets.graphics.ScreenCanvas

 -- @if GRAPHICS_NO_TEXT
 	 -- @error GRAPHICS_NO_TEXT flag is not yet supported by ScreenCanvas
 -- @endif

local redirect = term.redirect

local hex = {}
for i = 0, 15 do
	hex[2 ^ i] = ("%x"):format( i )
end

class "ScreenCanvas" extends "Canvas" {
	last = {};
}

function ScreenCanvas:ScreenCanvas( width, height )
	width = width or 0
	height = height or 0

	if type( width ) ~= "number" then return error( "element attribute #1 'width' not a number (" .. class.type( width ) .. ")", 2 ) end
	if type( height ) ~= "number" then return error( "element attribute #2 'height' not a number (" .. class.type( height ) .. ")", 2 ) end

	local t = {}

	self.last = {}
	for i = 1, width * height do
		self.last[i] = t
	end

	return self:Canvas( width, height )
end

function ScreenCanvas:reset()
	local t = {}
	for i = 1, self.width * self.height do
		self.last[i] = t
	end
end

function ScreenCanvas:draw_to_terminals( terminals, sx, sy )
	sx = sx or 0
	sy = sy or 0

	if type( terminals ) ~= "table" then
		return error( "expected table terminals, got " .. class.type( terminals ) )
	end
	if type( sx ) ~= "number" then return error( "expected number x, got " .. class.type( sx ) ) end
	if type( sy ) ~= "number" then return error( "expected number y, got " .. class.type( sy ) ) end

	local i = 1
	local buffer, last = self.buffer, self.last
	local s_width = self.width

	for y = 1, self.height do
		local changed = false
		for x = 1, s_width do

			local px = buffer[i]
			local ltpx = last[i]
			if px[1] ~= ltpx[1] or px[2] ~= ltpx[2] or px[3] ~= ltpx[3] then
				changed = true
				last[i] = px
			end

			i = i + 1
		end

		if changed then
			local bc, tc, s = {}, {}, {}
			i = i - s_width
			for x = 1, s_width do
				local px = buffer[i]
				bc[x] = hex[px[1]] or "0"
				tc[x] = hex[px[2]] or "0"
				s[x] = px[3] == "" and " " or px[3]
				i = i + 1
			end
			for i = 1, #terminals do
				terminals[i].setCursorPos( sx + 1, sy + y )
				terminals[i].blit( table.concat( s ), table.concat( tc ), table.concat( bc ) )
			end
		end
	end
end

function ScreenCanvas:draw_to_terminal( term, sx, sy )
	return self:draw_to_terminals( { term }, sx, sy )
end

function ScreenCanvas:draw_to_screen( x, y )
	return self:draw_to_terminal( term, x, y )
end
