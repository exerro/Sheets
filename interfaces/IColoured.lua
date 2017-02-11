
 -- @once
 -- @print Including sheets.interfaces.IColoured

interface "IColoured" {
	colour = WHITE;
}

function IColoured:IColoured()
	self.values:add( "colour", WHITE )
end
