
 -- @once
 -- @print Including sheets.interfaces.IColoured

interface "IColoured" {
	colour = nil;
}

function IColoured:IColoured()
	self.values:add( "colour", WHITE )
end
