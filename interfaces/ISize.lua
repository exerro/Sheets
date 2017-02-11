
 -- @once
 -- @print Including sheets.interfaces.ISize

interface "ISize" {
	width = 0;
	height = 0;
}

function ISize:ISize()
	local wsetter = Codegen.dynamic_property_setter( "width", {
		update_canvas_width = true
	} )
	local hsetter = Codegen.dynamic_property_setter( "height", {
		update_canvas_height = true
	} )
	self.values:add( "width", ValueHandler.integer_type, 0, wsetter )
	self.values:add( "height", ValueHandler.integer_type, 0, hsetter )
end
