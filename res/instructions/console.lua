
local module = {}

function module:error( data )
	error( data:gsub( "$([%w_]+)", function( v )
		return tostring( self.macros[v] or self.env[v] or "UNDEFINED" )
	end ), 0 )
end

function module:print( data )
	self:write ""
	print( (data:gsub( "$([%w_]+)", function( v )
		return tostring( self.macros[v] or self.env[v] or "UNDEFINED" )
	end )) )
end

return module
