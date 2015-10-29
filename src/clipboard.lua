
local c = {}

clipboard = {}

function clipboard.put( modes )
	c = modes
end

function clipboard.get( mode )
	return c[mode]
end

function clipboard.clear()
	c = {}
end
