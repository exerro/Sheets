
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
		local ok, data = pcall( env:getDecoder( node.nodetype ), node )
		if not ok then
			return false, data
		end
		return data, "decoder for " .. node.nodetype .. " returned nothing" -- data should be a true value, in which case the error is not needed
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
			local node, err = SML.loadNode( data[i] )
			if not node then
				return false, name .. " " .. tostring( err )
			end
			t[i] = node
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

end
