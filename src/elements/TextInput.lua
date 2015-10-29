
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.TextInput'
 -- @endif

 -- @print Including sheets.elements.TextInput

class "TextInput" extends "Sheet" {
	text = "";
	cursor = 0;
	scroll = 0;
	selection = false;
	focussed = false;
	handlesKeyboard = true;
	handlesText = true;
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
	self:setChanged()
end

function TextInput:setSelection( position )
	if type( position ) ~= "number" then return error( "expected number position, got " .. class.type( position ) ) end

	self.selection = position
	self:setChanged()
end

function TextInput:getSelectedText()
	return self.selection and self.text:sub( math.min( self.cursor, self.selection ) + 1, math.max( self.cursor, self.selection ) + 1 )
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
	self:setChanged()
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
	self.canvas:clear( self.theme:getField( self.class, "colour", self.focussed and "focussed" or "default" ) )

	if self.selection then
		local min = math.min( self.cursor, self.selection )
		local max = math.max( self.cursor, self.selection )

		self.canvas:drawText( -self.scroll, 0, self.text:sub( 1, min ), {
			textColour = self.theme:getField( self.class, "textColour", self.focussed and "focussed" or "default" );
		} )
		self.canvas:drawText( min - self.scroll, 0, self.text:sub( min + 1, max ), {
			colour = self.theme:getField( self.class, "colour", "highlighted" );
			textColour = self.theme:getField( self.class, "textColour", "highlighted" );
		} )
		self.canvas:drawText( max - self.scroll, 0, self.text:sub( max + 1 ), {
			textColour = self.theme:getField( self.class, "textColour", self.focussed and "focussed" or "default" );
		} )
	else
		self.canvas:drawText( -self.scroll, 0, self.text, {
			textColour = self.theme:getField( self.class, "textColour", self.focussed and "focussed" or "default" );
		} )
	end
	
	if not self.selection and self.focussed and self.cursor - self.scroll >= 0 and self.cursor - self.scroll < self.width then
		self:setCursorBlink( self.cursor - self.scroll, 0, self.theme:getField( self.class, "textColour", self.focussed and "focussed" or "default" ) )
	end
end

function TextInput:onMouseEvent( event )
	if self.down and event:is( SHEETS_EVENT_MOUSE_DRAG ) then
		self.selection = self.selection or self.cursor
		self:setCursor( event.x - self.scroll + 1 )
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
		self:setCursor( event.x - self.scroll )
		self.down = true
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) or event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		event:handle()
	end
end

function TextInput:onKeyboardEvent( event )
	if not self.focussed or event.handled then return end

	if event:is( SHEETS_EVENT_KEY_DOWN ) then
		if self.selection then
			if event:matches "left" then
				if event:isHeld "leftShift" or event:isHeld "rightShift" then
					self:setCursor( self.cursor - 1 )
				else
					self:setCursor( math.min( self.cursor, self.selection ) )
					self.selection = nil
				end
				event:handle()
			elseif event:matches "right" then
				if event:isHeld "leftShift" or event:isHeld "rightShift" then
					self:setCursor( self.cursor + 1 )
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
				self:setCursor( self.cursor - 1 )
				event:handle()
			elseif event:matches "right" then
				if event:isHeld "leftShift" or event:isHeld "rightShift" then
					self.selection = self.cursor
				end
				self:setCursor( self.cursor + 1 )
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
			if self.onEnter then
				self:onEnter()
			end
			event:handle()
		elseif event:matches "tab" then
			self:unfocus()
			if self.onTab then
				self:onTab()
			end
			event:handle()
		end

	end
end

function TextInput:onTextEvent( event )
	if not event.handled and self.focussed then
		self:write( event.text )
		event:handle()
	end
end

Theme.addToTemplate( TextInput, "colour", {
	default = LIGHTGREY;
	focussed = LIGHTGREY;
	highlighted = BLUE;
} )
Theme.addToTemplate( TextInput, "textColour", {
	default = GREY;
	focussed = GREY;
	highlighted = WHITE;
} )

Theme.addToTemplate( TextInput, "mask", {
	default = false;
	focussed = false;
} )
