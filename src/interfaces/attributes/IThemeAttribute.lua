
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IThemeAttribute'
 -- @endif

 -- @print Including sheets.interfaces.IThemeAttribute

IThemeAttribute = {}

function IThemeAttribute:attribute_theme( theme, node )
	local themeobj = SMLDocument.current():getTheme( theme )
	if themeobj then
		self:setTheme( themeobj )
	else
		return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: no such theme '" .. tostring( theme ) .. "'", 0 )
	end
end
