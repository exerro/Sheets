
 -- @print including(interfaces.IHasText)

local wrapline, wrap

@interface IHasText implements ISize {
	text = "";
	text_lines = nil;
	horizontal_alignment = ALIGNMENT_LEFT;
	vertical_alignment = ALIGNMENT_TOP;
	text_colour = WHITE;
}

function IHasText:IHasText()
	local function wrap()
		return self:wrap_text()
	end

	self.values:subscribe( "width", {}, wrap )
	self.values:subscribe( "text", {}, wrap )

	function self:IHasText() end
end

function IHasText:wrap_text()
	self.text_lines = wrap( self.text, self.width )
	self:set_changed()

	if #self.text_lines ~= self.line_count then
		self.line_count = #self.text_lines
		self.values:trigger "line_count"
	end
end

function IHasText:draw_text( surface, x, y )
	local offset, lines = 0, self.text_lines
	local linec = #self.text_lines

	if linec > self.height then
		linec = self.height
	end

	local horizontal_alignment = self.horizontal_alignment
	local vertical_alignment = self.vertical_alignment

	if not lines then
		self:wrap_text()
		lines = self.text_lines
	end

	if vertical_alignment == ALIGNMENT_CENTRE then
		offset = math.floor( self.height / 2 - linec / 2 + .5 )
	elseif vertical_alignment == ALIGNMENT_BOTTOM then
		offset = self.height - linec
	end

	for i = 1, linec do

		local x_offset = 0
		if horizontal_alignment == ALIGNMENT_CENTRE then
			x_offset = math.floor( self.width / 2 - #lines[i] / 2 + .5 )
		elseif horizontal_alignment == ALIGNMENT_RIGHT then
			x_offset = self.width - #lines[i]
		end

		surface:drawString( x + x_offset, y + offset + i - 1, lines[i], nil, self.text_colour )

	end
end

function IHasText:on_pre_draw()
	self:draw_text "default"
end

function wrapline( text, width )
	if text:sub( 1, width ):find "\n" then
		return text:match "^(.-)\n[^%S\n]*(.*)$"
	end
	if #text <= width then
		return text
	end
	for i = width + 1, 1, -1 do
		if text:sub( i, i ):find "%s" then
			return text:sub( 1, i - 1 ):gsub( "[^%S\n]+$", "" ), text:sub( i + 1 ):gsub( "^[^%S\n]+", "" )
		end
	end
	return text:sub( 1, width ), text:sub( width + 1 )
end

function wrap( text, width )
	local lines, line = {}
	while text do
		line, text = wrapline( text, width )
		lines[#lines + 1] = line
	end
	return lines
end
