
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ICommon'
 -- @endif

 -- @print Including sheets.interfaces.ICommon

ICommon = {
	changed = true;
	id = "ID";
	style = nil;
	cursor_x = 0;
	cursor_y = 0;
	cursor_colour = 0;
	cursor_active = false;
}

function ICommon:ICommon()
	self.style = Style( self )
end

function ICommon:setChanged( state )
	self.changed = state ~= false
	if state ~= false and self.parent and not self.parent.changed then
		self.parent:setChanged( true )
	end
	return self
end

function ICommon:setID( id )
	self.id = tostring( id )
	return self
end

function ICommon:setStyle( style, children )
	if not class.typeOf( style, Style ) then return error( "expected Style style, got " .. type( style ) ) end

	self.style = style:clone( self )
	
	if children and self.children then
		for i = 1, #self.children do
			self.children[i]:setStyle( style, true )
		end
	end

	self:setChanged( true )
	return self
end

function ICommon:setCursorBlink( x, y, colour )
	if type( x ) ~= "number" then return error( "expected number x, got " .. class.type( x ) ) end
	if type( y ) ~= "number" then return error( "expected number y, got " .. class.type( y ) ) end
	if colour and type( colour ) ~= "number" then return error( "expected number colour, got " .. class.type( colour ) ) end

	self.cursor_active = true
	self.cursor_x = x
	self.cursor_y = y
	self.cursor_colour = colour or GREY
	return self
end

function ICommon:resetCursorBlink()
	self.cursor_active = false
	return self
end
