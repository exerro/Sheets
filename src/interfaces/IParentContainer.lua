
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IParentContainer'
 -- @endif

 -- @print Including sheets.interfaces.IParentContainer

IParentContainer = {}

IParentContainer.parent = nil

function IParentContainer:setParent( parent )
	-- @if SHEETS_TYPE_CHECK
		if parent ~= nil and ( not class.isInstance( parent ) or not parent:implements( IChildContainer ) ) then return error( "expected IChildContainer parent, got " .. class.type( parent ) ) end
	-- @endif
	if parent then
		parent:addChild( self )
	else
		self:remove()
	end
	return self
end

function IParentContainer:remove()
	if self.parent then
		return self.parent:removeChild( self )
	end
end
