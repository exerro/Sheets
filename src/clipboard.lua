
local c = {}

clipboard = {}

function clipboard.put( modes )
	if type( modes ) ~= "table" then return error( "expected table modes, got " .. class.type( modes ) ) end
	c = modes
end

function clipboard.get( mode )
	if type( mode ) ~= "string" then return error( "expected string mode, got " .. class.type( mode ) ) end
	return c[mode]
end

function clipboard.clear()
	c = {}
end
