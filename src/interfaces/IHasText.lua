
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IHasText'
 -- @endif

 -- @print Including sheets.interfaces.IHasText

local wrapline, wrap

IHasText = {
	text = "";
	horizontal_alignment = ALIGNMENT_LEFT;
	vertical_alignment = ALIGNMENT_TOP;
	text_lines = {};
}

function IHasText:setText( text )
	if type( text ) ~= "string" then return error( "expected string text, got " .. class.type( text ) ) end

	self.text = text
	self:wrapText()
	self:setChanged()
	return self
end

function IHasText:setVerticalAlignment( alignment )
	if alignment ~= ALIGNMENT_TOP and alignment ~= ALIGNMENT_CENTRE and alignment ~= ALIGNMENT_BOTTOM then return error( "invalid alignment" ) end

	self.vertical_alignment = alignment
	self:wrapText()
	self:setChanged()

	return self
end

function IHasText:setHorizontalAlignment( alignment )
	if alignment ~= ALIGNMENT_LEFT and alignment ~= ALIGNMENT_CENTRE and alignment ~= ALIGNMENT_RIGHT then return error( "invalid alignment" ) end

	self.horizontal_alignment = alignment
	self:wrapText()
	self:setChanged()

	return self
end

function IHasText:wrapText()
	self.lines = wrap( self.text, self.width, self.height )
end

function IHasText:drawText( mode )
	local offset, lines = 0, self.lines
	mode = mode or "default"

	if not lines then
		self:wrapText()
		lines = self.lines
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

function IHasText:onPreDraw()
	self:drawText "default"
end

function wrapline( text, width )
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

function wrap( text, width, height )
	local lines, line = {}
	while text and #lines < height do
		line, text = wrapline( text, width )
		lines[#lines + 1] = line
	end
	return lines
end
