
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ICommon'
 -- @endif

 -- @print Including sheets.interfaces.ICommon

ICommon = {
	changed = true;
	id = "ID";
	theme = nil;
	cursor_x = 0;
	cursor_y = 0;
	cursor_colour = 0;
	cursor_active = false;
}

function ICommon:ICommon()
	self.theme = Theme()
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

function ICommon:setTheme( theme, children )
	if not class.typeOf( theme, Theme ) then return error( "expected Theme theme, got " .. type( theme ) ) end

	self.theme = theme
	
	if children and self.children then
		for i = 1, #self.children do
			self.children[i]:setTheme( theme, true )
		end
	end

	self:setChanged( true )
	return self
end

function ICommon:setCursor( x, y, colour )
	self.cursor_active = true
	self.cursor_x = x
	self.cursor_y = y
	self.cursor_colour = colour or GREY
end

function ICommon:resetCursor()
	self.cursor_active = false
end
