
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IHasText'
 -- @endif

 -- @print Including sheets.interfaces.IHasText

local wrapline, wrap

IHasText = {
	text = "";
	text_lines = {};
}

function IHasText:setText( text )
	functionParameters.check( 1, "text", "string", text )

	self.text = text
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

	local horizontal_alignment = self.style:getField( "horizontal-alignment." .. mode )
	local vertical_alignment = self.style:getField( "vertical-alignment." .. mode )

	if not lines then
		self:wrapText()
		lines = self.lines
	end

	if vertical_alignment == ALIGNMENT_CENTRE then
		offset = math.floor( self.height / 2 - #lines / 2 + .5 )
	elseif vertical_alignment == ALIGNMENT_BOTTOM then
		offset = self.height - #lines
	end

	for i = 1, #lines do

		local xOffset = 0
		if horizontal_alignment == ALIGNMENT_CENTRE then
			xOffset = math.floor( self.width / 2 - #lines[i] / 2 + .5 )
		elseif horizontal_alignment == ALIGNMENT_RIGHT then
			xOffset = self.width - #lines[i]
		end

		self.canvas:drawText( xOffset, offset + i - 1, lines[i], {
			colour = 0;
			textColour = self.style:getField( "textColour." .. mode );
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
