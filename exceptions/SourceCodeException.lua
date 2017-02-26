
 -- @print including(exceptions.SourceCodeException)

@private
@class SourceCodeException extends Exception {
	source = "";
	line = 0;
	character = 0
}

function SourceCodeException:SourceCodeException( data, source, character, strline, line )
	parameters.check_constructor( self.class, 5,
		"data", "string", data,
		"source", "string", source,
		"character", "number", character,
		"strline", "string", strline,
		"line", "number", line or 0
	)
	self.source = source
	self.line = line or 0
	self.character = character
	self.strline = strline

	return self:Exception( self:type(), data, 0 )
end

function SourceCodeException:get_data( indent )
	local srcstr = self.line ~= 0
	           and self.source .. "[" .. self.line .. ", " .. self.character .. "]: "
	            or self.source .. "[" .. self.character .. "]: "
	local posptr = (" "):rep( self.character - 1 ) .. "^"
	return srcstr .. self.data .. "\n" .. self.strline:gsub( "\t", " " ) .. "\n" .. posptr
end
