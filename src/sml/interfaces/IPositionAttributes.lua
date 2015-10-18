
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPositionAttributes'
 -- @endif

 -- @print Including sheets.interfaces.IPositionAttributes

IPositionAttributes = {}

function IPositionAttributes:attribute_x( x )
	return self:setX( x )
end

function IPositionAttributes:attribute_y( y )
	return self:setY( y )
end

function IPositionAttributes:attribute_width( width )
	return self:setWidth( width )
end

function IPositionAttributes:attribute_height( height )
	return self:setHeight( height )
end
