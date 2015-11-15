
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.ISize'
 -- @endif

 -- @print Including sheets.interfaces.ISize

interface "ISize" {
	width = 0;
	height = 0;
}

function ISize:setWidth( width )
	parameters.check( 1, "width", "number", width )

	if self.width ~= width then
		self.width = width
		self.canvas:setWidth( width )
		self:setChanged()

		for i = 1, #self.children do
			self.children[i]:onParentResized()
		end
	end
	return self
end

function ISize:setHeight( height )
	parameters.check( 1, "height", "number", height )

	if self.height ~= height then
		self.height = height
		self.canvas:setHeight( height )
		self:setChanged()
		
		for i = 1, #self.children do
			self.children[i]:onParentResized()
		end
	end
	return self
end
