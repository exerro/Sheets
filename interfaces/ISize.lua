
 -- @once
 -- @print Including sheets.interfaces.ISize

interface "ISize" {
	width = 0;
	height = 0;
}

function ISize:set_width( width )
	parameters.check( 1, "width", "number", width )

	if self.width ~= width then
		self.width = width
		self.canvas:set_width( width )
		self:set_changed()

		for i = 1, #self.children do
			self.children[i]:on_parent_resized()
		end
	end
	return self
end

function ISize:set_height( height )
	parameters.check( 1, "height", "number", height )

	if self.height ~= height then
		self.height = height
		self.canvas:set_height( height )
		self:set_changed()

		for i = 1, #self.children do
			self.children[i]:on_parent_resized()
		end
	end
	return self
end
