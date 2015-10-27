
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.TextInput'
 -- @endif

 -- @print Including sheets.TextInput

class "TextInput" extends "Sheet" {
	text = "";
	cursor = 0;
	scroll = 0;
	selection = false;
	focussed = false;
}

function TextInput:TextInput( x, y, width )
	return self:Sheet( x, y, width, 1 )
end

function TextInput:setText( text )
	self.text = text
	return self:setChanged()
end

function TextInput:setScroll( scroll )
	self.scroll = scroll
	return self:setChanged()
end

function TextInput:setCursorPosition( cursor )
	self.cursor = cursor
end

function TextInput:setSelectionPosition()

end

function TextInput:getSelectedText()
	return self.selection and self.text:sub( math.min( self.cursor, self.selection ) + 1, math.max( self.cursor, self.selection ) + 1 )
end

function TextInput:write( text )

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
	
	if self.focussed then
		self:setCursor( self.cursor, 0, self.theme:getField( self.class, "textColour", self.focussed and "focussed" or "default" ) )
	end
end

function TextInput:onMouseEvent( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:setChanged()
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
		self:unfocus()
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) then
		self:focus()
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		event:handle()
	end
end

Theme.addToTemplate( TextInput, "colour", {
	default = LIGHTGREY;
	focussed = WHITE;
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
