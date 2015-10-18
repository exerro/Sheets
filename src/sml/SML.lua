
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.sml.SML'
 -- @endif

 -- @print Including sheets.sml.SML

SML = {}

function SML.loadNode( node )
	 -- @if SHEETS_TYPE_CHECK
		if not class.typeOf( node, SMLNode ) then return error( "expected SMLNode node, got " .. class.type( node ) ) end
	 -- @endif
	local env = SMLEnvironment.current()
	if env:getDecoder( node.nodetype ) then
		return env:getDecoder( node.nodetype ):decode( node )
	end
end

function SML.load( script, name )
	name = name or "sml-script"
	 -- @if SHEETS_TYPE_CHECK
		if type( script ) ~= "string" then return error( "expected string script, got " .. class.type( script ) ) end
		if type( name ) ~= "string" then return error( "expected string source, got " .. class.type( name ) ) end
	 -- @endif
	SMLEnvironment.current()
	local ok, data = pcall( function()
		local parser = SMLParser( script )
		parser:begin()
		return parser:parseBody()
	end )

	if ok then
		local t = {}
		for i = 1, #data do
			local object, err = SML.loadNode( data[i] )
			if not object then
				return false, name .. " " .. tostring( err )
			end
			t[#t + 1] = object
		end
		return t
	else
		return false, name .. " " .. data
	end
end

function SML.loadFile( file )
	 -- @if SHEETS_TYPE_CHECK
		if type( file ) ~= "string" then return error( "expected string file, got " .. class.type( file ) ) end
	 -- @endif
	SMLEnvironment.current()
	local h = fs.open( file, "r" )
	if h then
		local content = h.readAll()
		h.close()
		return SML.load( content, fs.getName( file ) )
	else
		return false, "failed to open file"
	end
end
