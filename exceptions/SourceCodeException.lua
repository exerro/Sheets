
 -- @print including(exceptions.SourceCodeException)

@private
@class SourceCodeException extends Exception {
	source = "";
	line = 0;
	character = 0
}

function SourceCodeException:SourceCodeException( data, position )
	parameters.check_constructor( self.class, 2,
		"data", "string", data,
		"position", "table", position
	)
	self.position = position

	return self:Exception( self:type(), data, 1, true )
end

function SourceCodeException:get_data( indent )
	local srcstr = self.position.line ~= 0
	           and self.position.source .. "[" .. self.position.line .. ", " .. self.position.character .. "]: "
	            or self.position.source .. "[" .. self.position.character .. "]: "
	local posptr = (" "):rep( self.position.character - 1 ) .. "^"
	return srcstr .. self.data .. "\n" .. self.position.strline:gsub( "\t", " " ) .. "\n" .. posptr
end
