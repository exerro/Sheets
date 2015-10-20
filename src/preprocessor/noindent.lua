
local module = {}

function module:noindent()
	local oldwrite = self.write
	function self:write( text )
		oldwrite( self, text:gsub( "^[^%S\n]+", "" ) )
	end
end

return module
