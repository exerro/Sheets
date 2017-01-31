
 -- @once
 -- @print Including sheets.interfaces.IHasText

local wrapline, wrap

interface "IHasText" {
	text = "";
	text_lines = nil;
}

function IHasText:IHasText()
	self.values:add( "text", ValueHandler.string_type, "", Codegen.dynamic_property_setter( "text", { text_value = true, custom_update_code = "self:wrap_text()" } ) )
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

function IHasText:draw_text( mode )
	local offset, lines = 0, self.text_lines
	mode = mode or "default"

	local horizontal_alignment = self.style:get( "horizontal-alignment." .. mode )
	local vertical_alignment = self.style:get( "vertical-alignment." .. mode )

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

		self.canvas:draw_text( x_offset, offset + i - 1, lines[i], {
			colour = 0;
			text_colour = self.style:get( "text-colour." .. mode );
		} )

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
