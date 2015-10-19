
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ITextRenderer'
 -- @endif

 -- @print Including sheets.interfaces.ITextRenderer

local function wrapline( text, width )
	if text:sub( 1, width ):find "\n" then
		return text:match "^(.-)\n[^%S\n]*(.*)$"
	end
	if #text < width then
		return text
	end
	for i = width + 1, 1, -1 do
		if text:sub( i, i ):find "%s" then
			return text:sub( 1, i - 1 ):gsub( "[^%S\n]+$", "" ), text:sub( i + 1 ):gsub( "^[^%S\n]+", "" )
		end
	end
	return text:sub( 1, width ), text:sub( width + 1 )
end

local function wrap( text, width, height )
	local lines, line = {}
	while text and #lines < height do
		line, text = wrapline( text, width )
		lines[#lines + 1] = line
	end
	return lines
end

ITextRenderer = {
	text = "";
	horizontal_alignment = ALIGNMENT_LEFT;
	vertical_alignment = ALIGNMENT_TOP;
	text_lines = {};
}

function ITextRenderer:setText( text )
	 -- @if SHEETS_TYPE_CHECK
	 	if type( text ) ~= "string" then return error( "expected string text, got " .. class.type( text ) ) end
	 -- @endif
	self.text = text
	self:wrapText()
	self:setChanged()
	return self
end

function ITextRenderer:wrapText()
	self.lines = wrap( self.text, self.width, self.height )
	return self.lines
end

function ITextRenderer:drawText( mode )
	local offset, lines = 0, self.lines
	mode = mode or "default"

	if not lines then
		lines = self:wrapText()
	end

	if self.vertical_alignment == ALIGNMENT_CENTRE then
		offset = math.floor( self.height / 2 - #lines / 2 + .5 )
	elseif self.vertical_alignment == ALIGNMENT_BOTTOM then
		offset = self.height - #lines
	end

	for i = 1, #lines do

		local xOffset = 0
		if self.horizontal_alignment == ALIGNMENT_CENTRE then
			xOffset = math.floor( self.width / 2 - #lines[i] / 2 + .5 )
		elseif self.horizontal_alignment == ALIGNMENT_RIGHT then
			xOffset = self.width - #lines[i]
		end

		self.canvas:drawText( xOffset, offset + i - 1, lines[i], {
			colour = self.theme:getField( self.class, "colour", mode );
			textColour = self.theme:getField( self.class, "textColour", mode );
		} )

	end
end

function ITextRenderer:onPreDraw()
	self:drawText()
end
