
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IChildContainer'
 -- @endif

 -- @print Including sheets.interfaces.IChildContainer

IChildContainer = {}

IChildContainer.children = {}

function IChildContainer:IChildContainer()
	self.children = {}

	self.meta.__add = self.addChild

	function self.meta:__concat( child )
		self:addChild( child )
		return self
	end
end

function IChildContainer:addChild( child )
	if not class.typeOf( child, Sheet ) then return error( "expected Sheet child, got " .. class.type( child ) ) end

	if child.parent then
		child.parent:removeChild( child )
	end

	self:setChanged( true )
	child.parent = self
	if child.theme == default_theme then
		child:setTheme( self.theme )
	end
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
	 if type( id ) ~= "string" then return error( "expected string id, got " .. class.type( id ) ) end

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
	 if type( id ) ~= "string" then return error( "expected string id, got " .. class.type( id ) ) end

	local t = {}
	for i = #self.children, 1, -1 do
		local subt = self.children[i]:getChildById( id )
		for i = 1, #subt do
			t[#t + 1] = subt[i]
		end
		if self.children[i].id == id then
			t[#t + 1] = self.children[i]
		end
	end
	return t
end

function IChildContainer:isChildVisible( child )
	return child.x + child.width > 0 and child.y + child.height > 0 and child.x < self.width and child.y < self.height
end
