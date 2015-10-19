
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPositionAttributes'
 -- @endif

 -- @print Including sheets.interfaces.IPositionAttributes

IPositionAttributes = {}

function IPositionAttributes:attribute_x( x, node )
	if type( x ) == "number" then
		return self:setX( x )
	else
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: attribute 'x' is not a number (" .. type( x ), 0 )
	end
end

function IPositionAttributes:attribute_y( y, node )
	if type( y ) == "number" then
		return self:setY( y )
	else
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: attribute 'y' is not a number (" .. type( y ), 0 )
	end
end

function IPositionAttributes:attribute_width( width, node )
	if type( width ) == "number" then
		return self:setWidth( width )
	else
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: attribute 'width' is not a number (" .. type( width ), 0 )
	end
end

function IPositionAttributes:attribute_height( height, node )
	if type( height ) == "number" then
		return self:setHeight( height )
	else
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: attribute 'height' is not a number (" .. type( height ), 0 )
	end
end
