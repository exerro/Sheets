
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IChildContainer'
 -- @endif

 -- @print Including sheets.interfaces.IChildContainer

IChildContainer = {}

IChildContainer.children = {}

function IChildContainer:IChildContainer()
	self.children = {}
end

function IChildContainer:addChild( child )
	-- @if SHEETS_TYPE_CHECK
		if not class.typeOf( child, Sheet ) and not class.typeOf( child, View ) then return error( "expected Sheet child, got " .. class.type( child ) ) end
	-- @endif

	if child.parent then
		child.parent:removeChild( child )
	end

	self:setChanged( true )
	child.parent = self
	child:setTheme( self.theme )
	self.children[#self.children + 1] = child
	return child
end

function IChildContainer:removeChild( child )
	for i = #self.children, 1, -1 do
		if self.children[i] == child then
			self:setChanged( true )
			child.parent = nil

			return table.remove( self.children, i )
		end
	end
end

function IChildContainer:getChildById( id )
	for i = #self.children, 1, -1 do
		local c = self.children[i]:getChildById( id )
		if c then
			return c
		elseif self.children[i].id == id then
			return self.children[i]
		end
	end
end

function IChildContainer:getChildrenById( id )
	local t = {}
	for i = #children, 1, -1 do
		local subt = children[i]:getChildById( id )
		for i = 1, #subt do
			t[#t + 1] = subt[i]
		end
		if children[i].id == id then
			t[#t + 1] = children[i]
		end
	end
	return t
end
