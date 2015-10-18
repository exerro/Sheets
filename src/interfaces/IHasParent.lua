
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IHasParent'
 -- @endif

 -- @print Including sheets.interfaces.IHasParent

IHasParent = {}

IHasParent.parent = nil

function IHasParent:setParent( parent )
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

function IHasParent:remove()
	if self.parent then
		return self.parent:removeChild( self )
	end
end
