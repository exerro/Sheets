
 -- @once
 -- @print Including sheets.elements.TextInput

-- needs to update to new exception system

local function get_similar_pattern( char )
	local pat = "^[^_%w%s]+"
	if char:find "%s" then
		pat = "^%s+"
	elseif char:find "[%w_]" then
		pat = "^[%w_]+"
	end
	return pat
end

local function extend_selection( text, forward, pos )
	local pat = get_similar_pattern( text:sub( pos, pos ) )
	if forward then
		return #( text:match( pat, pos ) or "" )
	else
		local reverse = text:reverse()
		local newpos = #text - pos + 1
		return #( reverse:match( pat, newpos ) or "" )
	end
end

local function mask( text, mask )
	if mask then
		return mask:rep( #text )
	end
	return text
end

class "TextInput" extends "Sheet" {
	text = "";
	cursor = 0;
	scroll = 0;
	selection = false;
	focussed = false;
	handles_keyboard = true;
	handles_text = true;
	double_click_data = false;
}

function TextInput:TextInput( x, y, width )
	return self:Sheet( x, y, width, 1 )
end

function TextInput:set_text( text )
	self.text = tostring( text )
	return self:set_changed()
end

function TextInput:set_scroll( scroll )
	parameters.check( 1, "scroll", "number", scroll )

	self.scroll = scroll
	return self:set_changed()
end

function TextInput:set_cursor( cursor )
	parameters.check( 1, "cursor", "number", cursor )

	self.cursor = math.min( math.max( cursor, 0 ), #self.text )
	if self.cursor == self.selection then
		self.selection = nil
	end
	if self.cursor - self.scroll < 1 then
		self.scroll = math.max( self.cursor - 1, 0 )
	elseif self.cursor - self.scroll > self.width - 1 then
		self.scroll = self.cursor - self.width + 1
	end
	return self:set_changed()
end

function TextInput:set_selection( position )
	parameters.check( 1, "position", "number", position )

	self.selection = position
	return self:set_changed()
end

function TextInput:get_selected_text()
	return self.selection and self.text:sub( math.min( self.cursor, self.selection ) + 1, math.max( self.cursor, self.selection ) )
end

function TextInput:write( text )
	text = tostring( text )

	if self.selection then
		self.text = self.text:sub( 1, math.min( self.cursor, self.selection ) ) .. text .. self.text:sub( math.max( self.cursor, self.selection ) + 1 )
		self:set_cursor( math.min( self.cursor, self.selection ) + #text )
		self.selection = false
	else
		self.text = self.text:sub( 1, self.cursor ) .. text .. self.text:sub( self.cursor + 1 )
		self:set_cursor( self.cursor + #text )
	end
	return self:set_changed()
end

function TextInput:focus()
	if not self.focussed then
		self.focussed = true
		if self.on_focus then
			self:on_focus()
		end
		return self:set_changed()
	end
	return self
end

function TextInput:unfocus()
	if self.focussed then
		self.focussed = false
		if self.on_un_focus then
			self:on_un_focus()
		end
		return self:set_changed()
	end
	return self
end

function TextInput:on_pre_draw()
	self.canvas:clear( self.style:get( "colour." .. ( self.focussed and "focussed" or "default" ) ) )

	local masking = self.style:get( "mask." .. ( self.focussed and "focussed" or "default" ) )

	if self.selection then
		local min = math.min( self.cursor, self.selection )
		local max = math.max( self.cursor, self.selection )

		self.canvas:draw_text( -self.scroll, 0, mask( self.text:sub( 1, min ), masking ), {
			text_colour = self.style:get( "text-colour." .. ( self.focussed and "focussed" or "default" ) );
		} )
		self.canvas:draw_text( min - self.scroll, 0, mask( self.text:sub( min + 1, max ), masking ), {
			colour = self.style:get "colour.highlighted";
			text_colour = self.style:get "text-colour.highlighted";
		} )
		self.canvas:draw_text( max - self.scroll, 0, mask( self.text:sub( max + 1 ), masking ), {
			text_colour = self.style:get( "text-colour." .. ( self.focussed and "focussed" or "default" ) );
		} )
	else
		self.canvas:draw_text( -self.scroll, 0, mask( self.text, masking ), {
			text_colour = self.style:get( "text-colour." .. ( self.focussed and "focussed" or "default" ) );
		} )
	end

	if not self.selection and self.focussed and self.cursor - self.scroll >= 0 and self.cursor - self.scroll < self.width then
		self:set_cursor_blink( self.cursor - self.scroll, 0, self.style:get( "text-colour." .. ( self.focussed and "focussed" or "default" ) ) )
	end
end

function TextInput:on_mouse_event( event )
	if self.down and event:is( EVENT_MOUSE_DRAG ) then
		self.selection = self.selection or self.cursor
		self:set_cursor( event.x + self.scroll + 1 )
	elseif self.down and event:is( EVENT_MOUSE_UP ) then
		self.down = false
	end

	if event.handled or not event:is_within_area( 0, 0, self.width, self.height ) or not event.within then
		if event:is( EVENT_MOUSE_DOWN ) then
			self:unfocus()
		end
		return
	end

	if event:is( EVENT_MOUSE_DOWN ) then
		self:focus()
		self.selection = nil
		self:set_cursor( event.x + self.scroll )
		self.down = true
		event:handle()
	elseif event:is( EVENT_MOUSE_CLICK ) then
		if self.double_click_data and self.double_click_data.x == event.x + self.scroll then
			local pos1, pos2 = event.x + self.scroll + 1, event.x + self.scroll + 1
			local pat = get_similar_pattern( self.text:sub( pos1, pos1 ) )
			while self.text:sub( pos1 - 1, pos1 - 1 ):find( pat ) do
				pos1 = pos1 - 1
			end
			while self.text:sub( pos2 + 1, pos2 + 1 ):find( pat ) do
				pos2 = pos2 + 1
			end
			self:set_cursor( pos2 )
			self.selection = pos1 - 1
			timer.cancel( self.double_click_data.timer )
			self.double_click_data = false
		else
			if self.double_click_data then
				timer.cancel( self.double_click_data.timer )
			end
			local t = timer.queue( 0.3, function()
				self.double_click_data = false
			end )
			self.double_click_data = { x = event.x + self.scroll, timer = t }
		end
	elseif event:is( EVENT_MOUSE_HOLD ) then
		event:handle()
	end
end

function TextInput:on_keyboard_event( event )
	if not self.focussed or event.handled then return end

	if event:is( EVENT_KEY_DOWN ) then
		if self.selection then
			if event:matches "left" then
				if event:is_held "left_shift" or event:is_held "right_shift" then
					local diff = 1
					if event:is_held "rightCtrl" or event:is_held "leftCtrl" then
						diff = extend_selection( self.text, false, self.cursor )
					end
					self:set_cursor( self.cursor - diff )
				else
					self:set_cursor( math.min( self.cursor, self.selection ) )
					self.selection = nil
				end
				event:handle()
			elseif event:matches "right" then
				if event:is_held "left_shift" or event:is_held "right_shift" then
					local diff = 1
					if event:is_held "rightCtrl" or event:is_held "leftCtrl" then
						diff = extend_selection( self.text, true, self.cursor + 1 )
					end
					self:set_cursor( self.cursor + diff )
				else
					self:set_cursor( math.max( self.cursor, self.selection ) )
					self.selection = nil
				end
				event:handle()
			elseif event:matches "backspace" or event:matches "delete" then
				self:write ""
				event:handle()
			end
		else
			if event:matches "left" then
				if event:is_held "left_shift" or event:is_held "right_shift" then
					self.selection = self.cursor
				end
				local diff = 1
				if event:is_held "rightCtrl" or event:is_held "leftCtrl" then
					diff = extend_selection( self.text, false, self.cursor )
				end
				self:set_cursor( self.cursor - diff )
				event:handle()
			elseif event:matches "right" then
				if event:is_held "left_shift" or event:is_held "right_shift" then
					self.selection = self.cursor
				end
				local diff = 1
				if event:is_held "rightCtrl" or event:is_held "leftCtrl" then
					diff = extend_selection( self.text, true, self.cursor + 1 )
				end
				self:set_cursor( self.cursor + diff )
				event:handle()
			elseif event:matches "backspace" and self.cursor > 0 then
				self.text = self.text:sub( 1, self.cursor - 1 ) .. self.text:sub( self.cursor + 1 )
				self:set_cursor( self.cursor - 1 )
				event:handle()
			elseif event:matches "delete" then
				self:set_text( self.text:sub( 1, self.cursor ) .. self.text:sub( self.cursor + 2 ) )
				event:handle()
			end
		end

		if event:matches "leftCtrl-a" or event:matches "rightCtrl-a" then
			self.selection = self.selection or self.cursor
			if self.selection > self.cursor then
				self.selection, self.cursor = self.cursor, self.selection
			end
			self:add_animation( "selection", self.set_selection, Animation():set_rounded():add_key_frame( self.selection, 0, .15 ) )
			self:add_animation( "cursor", self.set_cursor, Animation():set_rounded():add_key_frame( self.cursor, #self.text, .15 ) )
			event:handle()
		elseif event:matches "end" then
			self:add_animation( "cursor", self.set_cursor, Animation():set_rounded():add_key_frame( self.cursor, #self.text, .15 ) )
			event:handle()
		elseif event:matches "home" then
			self:add_animation( "cursor", self.set_cursor, Animation():set_rounded():add_key_frame( self.cursor, 0, .15 ) )
			event:handle()
		elseif event:matches "enter" then
			self:unfocus()
			event:handle()
			if self.on_enter then
				return self:on_enter()
			end
		elseif event:matches "tab" then
			self:unfocus()
			event:handle()
			if self.on_tab then
				return self:on_tab()
			end
		elseif event:matches "v" and ( event:is_held "leftCtrl" or event:is_held "rightCtrl" ) then
			local text = clipboard.get "plain-text"
			if text then
				self:write( text )
			end
		elseif event:matches "leftCtrl-c" or event:matches "rightCtrl-c" then
			if self.selection then
				clipboard.put {
					["plain-text"] = self:get_selected_text();
				}
			end
		elseif event:matches "leftCtrl-x" or event:matches "rightCtrl-x" then
			if self.selection then
				clipboard.put {
					["plain-text"] = self:get_selected_text();
				}
				self:write ""
			end
		end

		event:handle()

	end
end

function TextInput:on_text_event( event )
	if not event.handled and self.focussed then
		self:write( event.text )
		event:handle()
	end
end

Style.add_to_template( TextInput, {
	["colour"] = LIGHTGREY;
	["colour.focussed"] = LIGHTGREY;
	["colour.highlighted"] = BLUE;
	["text-colour"] = GREY;
	["text-colour.focussed"] = GREY;
	["text-colour.highlighted"] = WHITE;
	["mask"] = false;
	["mask.focussed"] = false;
} )
