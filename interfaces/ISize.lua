
 -- @once
 -- @print Including sheets.interfaces.ISize

interface "ISize" {
	width = 0;
	height = 0;
}

function ISize:ISize()
	self.values:add( "width", ValueHandler.integer_type, 0, Codegen.dynamic_property_setter( "width", { update_canvas_width = true } ) )
	self.values:add( "height", ValueHandler.integer_type, 0, Codegen.dynamic_property_setter( "height", { update_canvas_height = true } ) )
end
