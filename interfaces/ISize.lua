
 -- @once
 -- @print Including sheets.interfaces.ISize

interface "ISize" {
	width = 0;
	height = 0;
}

function ISize:ISize()
	self.values:add( "width", ValueHandler.integer_type, 0, function( self, width )
		parameters.check( 1, "width", "number", width )

		if self.width ~= width then
			self.width = width
			self.raw_width = width
			self.canvas:set_width( width )
			self:set_changed()
			self.values:trigger "width"

			if self.parent then
				self.parent:child_value_changed( self )
			end
		end

		return self
	end )

	self.values:add( "height", ValueHandler.integer_type, 0, function( self, height )
		parameters.check( 1, "height", "number", height )

		if self.height ~= height then
			self.height = height
			self.raw_height = height
			self.canvas:set_height( height )
			self:set_changed()
			self.values:trigger "height"

			if self.parent then
				self.parent:child_value_changed( self )
			end
		end

		return self
	end )
end
