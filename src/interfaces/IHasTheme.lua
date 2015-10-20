
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IHasTheme'
 -- @endif

 -- @print Including sheets.interfaces.IHasTheme

IHasTheme = {
	theme = nil;
}

function IHasTheme:setTheme( theme, children )
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
