
 -- @print including(interfaces.IHasText)

local wrapline, wrap

@interface IHasText {
	text = "";
	text_lines = nil;
	horizontal_alignment = ALIGNMENT_LEFT;
	vertical_alignment = ALIGNMENT_TOP;
	text_colour = WHITE;
}

function IHasText:IHasText()
	local function wrap()
		self:wrap_text()
		self:set_changed()
	end

	self.values:add( "text", "" )
	self.values:add( "text_colour", WHITE )
	self.values:add( "horizontal_alignment", ALIGNMENT_LEFT )
	self.values:add( "vertical_alignment", ALIGNMENT_TOP )
	self.values:subscribe( "width", {}, wrap )
	self.values:subscribe( "text", {}, wrap )
end

function IHasText:auto_height()
	if not self.text_lines then
		self:wrap_text( true )
	end

	return self:set_height( #self.text_lines )
end

function IHasText:wrap_text( ignore_height )
	self.text_lines = wrap( self.text, self.width, not ignore_height and self.height )
end

function IHasText:draw_text( surface, x, y )
	local offset, lines = 0, self.text_lines

	local horizontal_alignment = self.horizontal_alignment
	local vertical_alignment = self.vertical_alignment

	if not lines then
		self:wrap_text()
		lines = self.text_lines
	end

	if vertical_alignment == ALIGNMENT_CENTRE then
		offset = math.floor( self.height / 2 - #lines / 2 + .5 )
	elseif vertical_alignment == ALIGNMENT_BOTTOM then
		offset = self.height - #lines
	end

	for i = 1, #lines do

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

function wrap( text, width, height )
	local lines, line = {}
	while text and ( not height or #lines < height ) do
		line, text = wrapline( text, width )
		lines[#lines + 1] = line
	end
	return lines
end
