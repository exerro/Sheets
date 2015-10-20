
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ICommonAttributes'
 -- @endif

 -- @print Including sheets.interfaces.ICommonAttributes

IAnimatedPositionAttributes = {}

function IAnimatedPositionAttributes:attribute_targetX( value, node )
	if type( value ) ~= "number" then
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: expected number for 'targetX' attribute" )
	end
	self:transitionX( value )
end

function IAnimatedPositionAttributes:attribute_targetY( value, node )
	if type( value ) ~= "number" then
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: expected number for 'targetY' attribute" )
	end
	self:transitionY( value )
end

function IAnimatedPositionAttributes:attribute_targetWidth( value, node )
	if type( value ) ~= "number" then
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: expected number for 'targetWidth' attribute" )
	end
	self:transitionWidth( value )
end

function IAnimatedPositionAttributes:attribute_targetHeight( value, node )
	if type( value ) ~= "number" then
		error( "[" .. node.position.line .. ", " .. node.position.character .. "]: expected number for 'targetHeight' attribute" )
	end
	self:transitionHeight( value )
end
