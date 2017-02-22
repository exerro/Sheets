
 -- @print including(interfaces.IColoured)

@interface IColoured {
	colour = nil;
}

function IColoured:IColoured()
	self.values:add( "colour", WHITE )

	function self:IColoured() end
end
