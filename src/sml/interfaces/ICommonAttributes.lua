
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ICommonAttributes'
 -- @endif

 -- @print Including sheets.interfaces.ICommonAttributes

ICommonAttributes = {}

function ICommonAttributes:attribute_theme( theme, node )
	local themeobj = SMLDocument.current():getTheme( theme )
	if theme then
		self:setTheme( themeobj )
	else
		return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: no such theme '" .. tostring( theme ) .. "'", 0 )
	end
end

function ICommonAttributes:attribute_id( id )
	if self.setID then
		self:setID( id )
	end
end
