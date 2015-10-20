
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ITextAttributes'
 -- @endif

 -- @print Including sheets.interfaces.ITextAttributes

local a = {
	left = ALIGNMENT_LEFT;
	centre = ALIGNMENT_CENTRE;
	center = ALIGNMENT_CENTRE;
	right = ALIGNMENT_RIGHT;
	top = ALIGNMENT_TOP;
	bottom = ALIGNMENT_BOTTOM;
}

ITextAttributes = {}

function ITextAttributes:attribute_text( text )
	self:setText( tostring( text ) )
end

function ITextAttributes:attribute_horizontalAlignment( alignment, node )
	if alignment == "left" or alignment == "centre" or alignment == "center" or alignment == "right" then
		return self:setHorizontalAlignment( a[alignment] )
	else
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: attribute 'horizonalAlignment' is invalid", 0 )
	end
end

function ITextAttributes:attribute_verticalAlignment( alignment, node )
	if alignment == "top" or alignment == "centre" or alignment == "center" or alignment == "bottom" then
		return self:setVerticalAlignment( a[alignment] )
	else
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: attribute 'verticalAlignment' is invalid", 0 )
	end
end
