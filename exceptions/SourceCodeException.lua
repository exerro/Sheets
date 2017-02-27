
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
	local strline

	if self.position.start.line == self.position.finish.line then
		strline = self.position.lines[self.position.finish.line]:gsub( "\t", " " ) .. "\n"
		       .. (" "):rep( self.position.start.character - 1 ) .. ("^"):rep( self.position.finish.character - self.position.start.character + 1 ) .. " @ " .. self.position.source .. "[" .. self.position.start.line .. ", " .. self.position.start.character .. "]\n"
	else
		strline = "from " .. self.position.lines[self.position.start.line]:gsub( "\t", " " ) .. "\n"
		       .. (" "):rep( self.position.start.character + 4 ) .. ("^"):rep( #self.position.lines[self.position.start.line] - self.position.start.character + 1 ) .. " @ " .. self.position.source .. "[" .. self.position.start.line .. ", " .. self.position.start.character .. "]\n"
			   .. "  to " .. self.position.lines[self.position.finish.line]:gsub( "\t", " " ) .. "\n"
		       .. (" "):rep( self.position.start.character + 4 ) .. ("^"):rep( self.position.finish.character - self.position.start.character + 1 ) .. " @ " .. self.position.source .. "[" .. self.position.finish.line .. ", " .. self.position.finish.character .. "]\n"
	end

	return self.data .. "\n" .. strline
end
