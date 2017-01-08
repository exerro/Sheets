
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.Checkbox'
 -- @endif

 -- @print Including sheets.elements.Checkbox

class "Checkbox" extends "Sheet" {
	down = false;
	checked = false;
}

function Checkbox:Checkbox( x, y, checked )
	self.checked = checked
	self:Sheet( x, y, 1, 1 )
end

function Checkbox:setWidth() end
function Checkbox:setHeight() end

function Checkbox:toggle()
	self.checked = not self.checked
	if self.onToggle then
		self:onToggle()
	end
	if self.checked and self.onCheck then
		self:onCheck()
	elseif not self.checked and self.onUnCheck then
		self:onUnCheck()
	end
	self:setChanged()
end

function Checkbox:onPreDraw()
	self.canvas:drawPoint( 0, 0, {
		colour = self.style:getField( "colour." .. ( ( self.down and "pressed" ) or ( self.checked and "checked" ) or "default" ) );
		textColour = self.style:getField( "checkColour." .. ( self.down and "pressed" or "default" ) );
		character = self.checked and "x" or " ";
	} )
end

function Checkbox:onMouseEvent( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:setChanged()
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		self.down = true
		self:setChanged()
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) then
		self:toggle()
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		event:handle()
	end
end

Style.addToTemplate( Checkbox, {
	["colour"] = LIGHTGREY;
	["colour.checked"] = LIGHTGREY;
	["colour.pressed"] = GREY;
	["checkColour"] = BLACK;
	["checkColour.pressed"] = LIGHTGREY;
} )
