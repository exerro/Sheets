
 -- @once
 -- @print Including sheets.interfaces.ISize

interface "ISize" {
	width = 0;
	height = 0;
}

function ISize:ISize()
	self.values:add( "width", 0, { update_canvas_width = true } )
	self.values:add( "height", 0, { update_canvas_height = true } )
end
