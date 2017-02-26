
 -- @print including(interfaces.ITextRenderer)

 -- don't implement this without add_component('text', 'size')

local wrapline, wrap

@private
@interface ITextRenderer {

}

function ITextRenderer:ITextRenderer()
	local function wrap()
		return self:wrap_text()
	end

	self.values:subscribe( "width", {}, wrap )
	self.values:subscribe( "text", {}, wrap )
end

function ITextRenderer:wrap_text()
	if self.width <= 0 then
		self.text_lines = {}
	else
		self.text_lines = wrap( self.text, self.width )
	end
	self:set_changed()

	if #self.text_lines ~= self.line_count then
		self.line_count = #self.text_lines
		self.values:trigger "line_count"
	end
end

function ITextRenderer:draw_text( surface, x, y )
	local offset, lines = 0, self.text_lines
	local linec = #self.text_lines

	if linec > self.height then
		linec = self.height
	end

	local horizontal_alignment = self.horizontal_alignment
	local vertical_alignment = self.vertical_alignment

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

function wrapline( text, width )
	if text:sub( 1, width ):find "\n" then
		return text:match "^(.-)\n(.*)$"
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

	repeat
		line, text = wrapline( text, width )
		lines[#lines + 1] = line
	until not text

	return lines
end
