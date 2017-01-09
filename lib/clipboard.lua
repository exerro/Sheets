
local c = {}

clipboard = {}

function clipboard.put( modes )
	parameters.check( 1, "modes", "table", modes )
	c = modes
end

function clipboard.get( mode )
	parameters.check( 1, "mode", "string", mode )
	return c[mode]
end

function clipboard.clear()
	c = {}
end