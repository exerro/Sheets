
 -- @print including(interfaces.IColoured)

@interface IColoured {
	colour = nil;
}

function IColoured:IColoured()
	function self:IColoured() end
end
