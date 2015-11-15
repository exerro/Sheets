
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.graphics.DrawingCanvas'
 -- @endif

 -- @print Including sheets.graphics.DrawingCanvas

 -- @if GRAPHICS_NO_TEXT
 	 -- @error GRAPHICS_NO_TEXT flag is not yet supported by DrawingCanvas
 -- @endif

class "DrawingCanvas" extends "Canvas" {}

function DrawingCanvas:drawPoint( x, y, options )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	if type( options ) ~= "table" then return error( "expected table options, got " .. class.type( options ) ) end

	local colour = options.colour or TRANSPARENT
	local textColour = options.textColour or WHITE
	local character = options.character or " "

	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end
	if type( textColour ) ~= "number" then return error( "expected number textColour, got " .. class.type( textColour ) ) end
	if type( character ) ~= "string" then return error( "expected string character, got " .. class.type( character ) ) end

	if x >= 0 and y >= 0 and x < self.width and y < self.height then
		self:drawPixel( { y * self.width + x + 1 }, { colour, textColour, character } )
	end
end

function DrawingCanvas:drawBox( x, y, width, height, options )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end
	if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end
	if type( options ) ~= "table" then return error( "expected table options, got " .. class.type( options ) ) end

	local colour = options.colour or TRANSPARENT
	local textColour = options.textColour or WHITE
	local character = options.character or " "

	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end
	if type( textColour ) ~= "number" then return error( "expected number textColour, got " .. class.type( textColour ) ) end
	if type( character ) ~= "string" then return error( "expected string character, got " .. class.type( character ) ) end

	if character == " " then
		self:drawColour( self:getArea( GRAPHICS_AREA_BOX, x, y, width, height ), colour )
	else
		self:drawPixel( self:getArea( GRAPHICS_AREA_BOX, x, y, width, height ), { colour, textColour, character } )
	end
end

function DrawingCanvas:drawCircle( x, y, radius, options )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	if type( radius ) ~= "number" then return error( "expected number radius, got " .. class.type( radius ) ) end
	if type( options ) ~= "table" then return error( "expected table options, got " .. class.type( options ) ) end

	local colour = options.colour or TRANSPARENT
	local textColour = options.textColour or WHITE
	local character = options.character or " "
	local corrected = options.corrected or false

	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end
	if type( textColour ) ~= "number" then return error( "expected number textColour, got " .. class.type( textColour ) ) end
	if type( character ) ~= "string" then return error( "expected string character, got " .. class.type( character ) ) end

	if character == " " then
		self:drawColour( self:getArea( corrected and GRAPHICS_AREA_CCIRCLE or GRAPHICS_AREA_CIRCLE, x, y, radius ), colour )
	else
		self:drawPixel( self:getArea( corrected and GRAPHICS_AREA_CCIRCLE or GRAPHICS_AREA_CIRCLE, x, y, radius ), { colour, textColour, character } )
	end
end

function DrawingCanvas:drawLine( x1, y1, x2, y2, options )
	if type( x1 ) ~= "number" then return error( "expected number x1, got " .. class.type( x1 ) ) end
	if type( y1 ) ~= "number" then return error( "expected number y1, got " .. class.type( y1 ) ) end
	if type( x2 ) ~= "number" then return error( "expected number x2, got " .. class.type( x2 ) ) end
	if type( y2 ) ~= "number" then return error( "expected number y2, got " .. class.type( y2 ) ) end
	if type( options ) ~= "table" then return error( "expected table options, got " .. class.type( options ) ) end

	local colour = options.colour or TRANSPARENT
	local textColour = options.textColour or WHITE
	local character = options.character or " "

	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end
	if type( textColour ) ~= "number" then return error( "expected number textColour, got " .. class.type( textColour ) ) end
	if type( character ) ~= "string" then return error( "expected string character, got " .. class.type( character ) ) end

	if character == " " then
		self:drawColour( self:getArea( GRAPHICS_AREA_LINE, x1, y1, x2, y2 ), colour )
	else
		self:drawPixel( self:getArea( GRAPHICS_AREA_LINE, x1, y1, x2, y2 ), { colour, textColour, character } )
	end
end

function DrawingCanvas:drawHorizontalLine( x, y, width, options )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	if type( width ) ~= "number" then return error( "expected number width, got " .. class.type( width ) ) end
	if type( options ) ~= "table" then return error( "expected table options, got " .. class.type( options ) ) end

	local colour = options.colour or TRANSPARENT
	local textColour = options.textColour or WHITE
	local character = options.character or " "

	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end
	if type( textColour ) ~= "number" then return error( "expected number textColour, got " .. class.type( textColour ) ) end
	if type( character ) ~= "string" then return error( "expected string character, got " .. class.type( character ) ) end

	if character == " " then
		self:drawColour( self:getArea( GRAPHICS_AREA_HLINE, x, y, width ), colour )
	else
		self:drawPixel( self:getArea( GRAPHICS_AREA_HLINE, x, y, width ), { colour, textColour, character } )
	end
end

function DrawingCanvas:drawVerticalLine( x, y, height, options )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	if type( height ) ~= "number" then return error( "expected number height, got " .. class.type( height ) ) end
	if type( options ) ~= "table" then return error( "expected table options, got " .. class.type( options ) ) end

	local colour = options.colour or TRANSPARENT
	local textColour = options.textColour or WHITE
	local character = options.character or " "

	if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end
	if type( textColour ) ~= "number" then return error( "expected number textColour, got " .. class.type( textColour ) ) end
	if type( character ) ~= "string" then return error( "expected string character, got " .. class.type( character ) ) end

	if character == " " then
		self:drawColour( self:getArea( GRAPHICS_AREA_VLINE, x, y, height ), colour )
	else
		self:drawPixel( self:getArea( GRAPHICS_AREA_VLINE, x, y, height ), { colour, textColour, character } )
	end
end

 -- @if GRAPHICS_NO_TEXT


 -- @else
	function DrawingCanvas:drawText( x, y, text, options )
		if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
		if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
		if type( text ) ~= "string" then return error( "expected string text, got " .. class.type( text ) ) end
		if type( options ) ~= "table" then return error( "expected table options, got " .. class.type( options ) ) end

		local colour = options.colour or TRANSPARENT
		local textColour = options.textColour or WHITE

		if type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end
		if type( textColour ) ~= "number" then return error( "expected number textColour, got " .. class.type( textColour ) ) end

		if y < 0 or y >= self.height then return end -- no pixels to draw

		local sWidth = self.width
		local ypos = y * sWidth + ( x > 0 and x or 0 )
		local diff = x >= 0 and 0 or -x
		local t, p = {}, {}
		local w, w2 = sWidth - ( x > 0 and x or 0 ), #text - diff

		for i = 1, w < w2 and w or w2 do
			t[i] = { colour, textColour, text:sub( i + diff, i + diff ) }
			p[i] = ypos + i
		end

		self:drawPixels( p, t )
	end
 -- @endif
