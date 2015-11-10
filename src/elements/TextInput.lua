
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.TextInput'
 -- @endif

 -- @print Including sheets.elements.TextInput

-- needs to update to new exception system

local function getSimilarPattern( char )
	local pat = "^[^_%w%s]+"
	if char:find "%s" then
		pat = "^%s+"
	elseif char:find "[%w_]" then
		pat = "^[%w_]+"
	end
	return pat
end

local function extendSelection( text, forward, pos )
	local pat = getSimilarPattern( text:sub( pos, pos ) )
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
	handlesKeyboard = true;
	handlesText = true;
	doubleClickData = false;
}

function TextInput:TextInput( x, y, width )
	return self:Sheet( x, y, width, 1 )
end

function TextInput:setText( text )
	self.text = tostring( text )
	return self:setChanged()
end

function TextInput:setScroll( scroll )
	if type( scroll ) ~= "number" then return error( "expected number scroll, got " .. class.type( scroll ) ) end

	self.scroll = scroll
	return self:setChanged()
end

function TextInput:setCursor( cursor )
	if type( cursor ) ~= "number" then return error( "expected number cursor, got " .. class.type( cursor ) ) end

	self.cursor = math.min( math.max( cursor, 0 ), #self.text )
	if self.cursor == self.selection then
		self.selection = nil
	end
	if self.cursor - self.scroll < 1 then
		self.scroll = math.max( self.cursor - 1, 0 )
	elseif self.cursor - self.scroll > self.width - 1 then
		self.scroll = self.cursor - self.width + 1
	end
	return self:setChanged()
end

function TextInput:setSelection( position )
	if type( position ) ~= "number" then return error( "expected number position, got " .. class.type( position ) ) end

	self.selection = position
	return self:setChanged()
end

function TextInput:getSelectedText()
	return self.selection and self.text:sub( math.min( self.cursor, self.selection ) + 1, math.max( self.cursor, self.selection ) )
end

function TextInput:write( text )
	text = tostring( text )

	if self.selection then
		self.text = self.text:sub( 1, math.min( self.cursor, self.selection ) ) .. text .. self.text:sub( math.max( self.cursor, self.selection ) + 1 )
		self:setCursor( math.min( self.cursor, self.selection ) + #text )
		self.selection = false
	else
		self.text = self.text:sub( 1, self.cursor ) .. text .. self.text:sub( self.cursor + 1 )
		self:setCursor( self.cursor + #text )
	end
	return self:setChanged()
end

function TextInput:focus()
	if not self.focussed then
		self.focussed = true
		if self.onFocus then
			self:onFocus()
		end
		return self:setChanged()
	end
	return self
end

function TextInput:unfocus()
	if self.focussed then
		self.focussed = false
		if self.onUnFocus then
			self:onUnFocus()
		end
		return self:setChanged()
	end
	return self
end

function TextInput:onPreDraw()
	self.canvas:clear( self.style:getField( "colour." .. ( self.focussed and "focussed" or "default" ) ) )

	local masking = self.style:getField( "mask." .. ( self.focussed and "focussed" or "default" ) )

	if self.selection then
		local min = math.min( self.cursor, self.selection )
		local max = math.max( self.cursor, self.selection )

		self.canvas:drawText( -self.scroll, 0, mask( self.text:sub( 1, min ), masking ), {
			textColour = self.style:getField( "textColour." .. ( self.focussed and "focussed" or "default" ) );
		} )
		self.canvas:drawText( min - self.scroll, 0, mask( self.text:sub( min + 1, max ), masking ), {
			colour = self.style:getField "colour.highlighted";
			textColour = self.style:getField "textColour.highlighted";
		} )
		self.canvas:drawText( max - self.scroll, 0, mask( self.text:sub( max + 1 ), masking ), {
			textColour = self.style:getField( "textColour." .. ( self.focussed and "focussed" or "default" ) );
		} )
	else
		self.canvas:drawText( -self.scroll, 0, mask( self.text, masking ), {
			textColour = self.style:getField( "textColour." .. ( self.focussed and "focussed" or "default" ) );
		} )
	end
	
	if not self.selection and self.focussed and self.cursor - self.scroll >= 0 and self.cursor - self.scroll < self.width then
		self:setCursorBlink( self.cursor - self.scroll, 0, self.style:getField( "textColour." .. ( self.focussed and "focussed" or "default" ) ) )
	end
end

function TextInput:onMouseEvent( event )
	if self.down and event:is( SHEETS_EVENT_MOUSE_DRAG ) then
		self.selection = self.selection or self.cursor
		self:setCursor( event.x + self.scroll + 1 )
	elseif self.down and event:is( SHEETS_EVENT_MOUSE_UP ) then
		self.down = false
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
		if event:is( SHEETS_EVENT_MOUSE_DOWN ) then
			self:unfocus()
		end
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) then
		self:focus()
		self.selection = nil
		self:setCursor( event.x + self.scroll )
		self.down = true
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) then
		if self.doubleClickData and self.doubleClickData.x == event.x + self.scroll then
			local pos1, pos2 = event.x + self.scroll + 1, event.x + self.scroll + 1
			local pat = getSimilarPattern( self.text:sub( pos1, pos1 ) )
			while self.text:sub( pos1 - 1, pos1 - 1 ):find( pat ) do
				pos1 = pos1 - 1
			end
			while self.text:sub( pos2 + 1, pos2 + 1 ):find( pat ) do
				pos2 = pos2 + 1
			end
			self:setCursor( pos2 )
			self.selection = pos1 - 1
			timer.cancel( self.doubleClickData.timer )
			self.doubleClickData = false
		else
			if self.doubleClickData then
				timer.cancel( self.doubleClickData.timer )
			end
			local t = timer.queue( 0.3, function()
				self.doubleClickData = false
			end )
			self.doubleClickData = { x = event.x + self.scroll, timer = t }
		end
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		event:handle()
	end
end

function TextInput:onKeyboardEvent( event )
	if not self.focussed or event.handled then return end

	if event:is( SHEETS_EVENT_KEY_DOWN ) then
		if self.selection then
			if event:matches "left" then
				if event:isHeld "leftShift" or event:isHeld "rightShift" then
					local diff = 1
					if event:isHeld "rightCtrl" or event:isHeld "leftCtrl" then
						diff = extendSelection( self.text, false, self.cursor )
					end
					self:setCursor( self.cursor - diff )
				else
					self:setCursor( math.min( self.cursor, self.selection ) )
					self.selection = nil
				end
				event:handle()
			elseif event:matches "right" then
				if event:isHeld "leftShift" or event:isHeld "rightShift" then
					local diff = 1
					if event:isHeld "rightCtrl" or event:isHeld "leftCtrl" then
						diff = extendSelection( self.text, true, self.cursor + 1 )
					end
					self:setCursor( self.cursor + diff )
				else
					self:setCursor( math.max( self.cursor, self.selection ) )
					self.selection = nil
				end
				event:handle()
			elseif event:matches "backspace" or event:matches "delete" then
				self:write ""
				event:handle()
			end
		else
			if event:matches "left" then
				if event:isHeld "leftShift" or event:isHeld "rightShift" then
					self.selection = self.cursor
				end
				local diff = 1
				if event:isHeld "rightCtrl" or event:isHeld "leftCtrl" then
					diff = extendSelection( self.text, false, self.cursor )
				end
				self:setCursor( self.cursor - diff )
				event:handle()
			elseif event:matches "right" then
				if event:isHeld "leftShift" or event:isHeld "rightShift" then
					self.selection = self.cursor
				end
				local diff = 1
				if event:isHeld "rightCtrl" or event:isHeld "leftCtrl" then
					diff = extendSelection( self.text, true, self.cursor + 1 )
				end
				self:setCursor( self.cursor + diff )
				event:handle()
			elseif event:matches "backspace" and self.cursor > 0 then
				self.text = self.text:sub( 1, self.cursor - 1 ) .. self.text:sub( self.cursor + 1 )
				self:setCursor( self.cursor - 1 )
				event:handle()
			elseif event:matches "delete" then
				self:setText( self.text:sub( 1, self.cursor ) .. self.text:sub( self.cursor + 2 ) )
				event:handle()
			end
		end

		if event:matches "leftCtrl-a" or event:matches "rightCtrl-a" then
			self.selection = self.selection or self.cursor
			if self.selection > self.cursor then
				self.selection, self.cursor = self.cursor, self.selection
			end
			self:addAnimation( "selection", self.setSelection, Animation():setRounded():addKeyFrame( self.selection, 0, .15 ) )
			self:addAnimation( "cursor", self.setCursor, Animation():setRounded():addKeyFrame( self.cursor, #self.text, .15 ) )
			event:handle()
		elseif event:matches "end" then
			self:addAnimation( "cursor", self.setCursor, Animation():setRounded():addKeyFrame( self.cursor, #self.text, .15 ) )
			event:handle()
		elseif event:matches "home" then
			self:addAnimation( "cursor", self.setCursor, Animation():setRounded():addKeyFrame( self.cursor, 0, .15 ) )
			event:handle()
		elseif event:matches "enter" then
			self:unfocus()
			event:handle()
			if self.onEnter then
				return self:onEnter()
			end
		elseif event:matches "tab" then
			self:unfocus()
			event:handle()
			if self.onTab then
				return self:onTab()
			end
		elseif event:matches "v" and ( event:isHeld "leftCtrl" or event:isHeld "rightCtrl" ) then
			local text = clipboard.get "plain-text"
			if text then
				self:write( text )
			end
		elseif event:matches "leftCtrl-c" or event:matches "rightCtrl-c" then
			if self.selection then
				clipboard.put {
					["plain-text"] = self:getSelectedText();
				}
			end
		elseif event:matches "leftCtrl-x" or event:matches "rightCtrl-x" then
			if self.selection then
				clipboard.put {
					["plain-text"] = self:getSelectedText();
				}
				self:write ""
			end
		end

		event:handle()

	end
end

function TextInput:onTextEvent( event )
	if not event.handled and self.focussed then
		self:write( event.text )
		event:handle()
	end
end

Style.addToTemplate( TextInput, {
	["colour"] = LIGHTGREY;
	["colour.focussed"] = LIGHTGREY;
	["colour.highlighted"] = BLUE;
	["textColour"] = GREY;
	["textColour.focussed"] = GREY;
	["textColour.highlighted"] = WHITE;
	["mask"] = false;
	["mask.focussed"] = false;
} )
