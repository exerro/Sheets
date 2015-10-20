
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.sml.SMLDocument'
 -- @endif

 -- @print Including sheets.sml.SMLDocument

local active

local function copyt( o )
	local t = {}
	local k, v = next( o )
	while k do
		t[k] = v
		k, v = next( o, k )
	end
	return t
end

local function rawLoadNode( self, node, parent )
	local decoder = self:getDecoder( node.nodetype )
	if decoder then
		return decoder:decode( node, parent )
	else
		return false, "[" .. node.position.line .. ", " .. node.position.character .. "]: unknown node type '" .. node.nodetype .. "'"
	end
end

local function parseScript( script, name )
	return pcall( function()
		local parser = SMLParser( script )
		parser:begin()
		return parser:parseBody()
	end )
end

class "SMLDocument" {
	application = nil;
	themes = {};
	environment = {};
	decoders = {};
	elements = {};
}

function SMLDocument.current()
	return active
end

function SMLDocument:SMLDocument( application )
	self.application = application
	self.themes = copyt( SMLDocument.themes )
	self.environment = copyt( SMLDocument.environment )
	self.decoders = copyt( SMLDocument.decoders )
	self.elements = copyt( SMLDocument.elements )

	self.environment.document = self
	self.environment.application = self.application

	active = self
end

function SMLDocument:loadSMLNode( node, parent )
	 -- @if SHEETS_TYPE_CHECK
		if not class.typeOf( node, SMLNode ) then return error( "expected SMLNode node, got " .. class.type( node ) ) end
	 -- @endif
	active = self
	if not self.application then
		return error( "SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()" )
	end
	return rawLoadNode( self, node, parent )
end

function SMLDocument:loadSMLScript( script, name, parent )
	name = name or "sml-script"
	 -- @if SHEETS_TYPE_CHECK
		if type( script ) ~= "string" then return error( "expected string script, got " .. class.type( script ) ) end
		if type( name ) ~= "string" then return error( "expected string source, got " .. class.type( name ) ) end
	 -- @endif
	if not self.application then
		return error( "SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()" )
	end

	local ok, data = parseScript( script, name )

	if ok then
		local t = {}
		for i = 1, #data do
			local object, err = rawLoadNode( self, data[i], parent )
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

function SMLDocument:loadSMLFile( file, parent )
	 -- @if SHEETS_TYPE_CHECK
		if type( file ) ~= "string" then return error( "expected string file, got " .. class.type( file ) ) end
	 -- @endif
	if not self.application then
		return error( "SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()" )
	end
	local h = fs.open( file, "r" )
	if h then
		local content = h.readAll()
		h.close()
		return self:loadSMLScript( content, fs.getName( file ), parent )
	else
		return false, "failed to open file"
	end
end

function SMLDocument:loadSMLApplication( script, name )
	name = name or "sml-script"
	 -- @if SHEETS_TYPE_CHECK
		if type( script ) ~= "string" then return error( "expected string script, got " .. class.type( script ) ) end
		if type( name ) ~= "string" then return error( "expected string source, got " .. class.type( name ) ) end
	 -- @endif

	if self.application then
		return error "document already has an application"
	end

	local ok, data = parseScript( script, name )

	if ok then
		if #data == 1 then
			if data[1].nodetype == "application" then
				local application, err = rawLoadNode( self, data[1], self )
				if application and application:typeOf( Application ) then
					self.application = application
					self.environment.application = application
					return application
				elseif not application then
					return false, name .. " " .. tostring( err )
				else
					return error( "misconfigured Sheets installation, <application> node didn't return an Application" )
				end
			else
				return false, "[" .. data[1].position.line .. ", " .. data[1].position.character .. "]: expected application node, got " .. data[1].nodetype
			end
		elseif data[2] then
			return false, "[" .. data[2].position.line .. ", " .. data[2].position.character .. "]: unexpected node '" .. data[2].nodetype .. "'"
		else
			return false, "expected application node, got nothing"
		end
	else
		return false, name .. " " .. data
	end
end

function SMLDocument:loadSMLApplicationFile( file )
	 -- @if SHEETS_TYPE_CHECK
		if type( file ) ~= "string" then return error( "expected string file, got " .. class.type( file ) ) end
	 -- @endif

	if self.application then
		return error "document already has an application"
	end

	local h = fs.open( file, "r" )
	if h then
		local content = h.readAll()
		h.close()
		return self:loadSMLApplication( content, fs.getName( file ) )
	else
		return false, "failed to open file"
	end
end

function SMLDocument:setTheme( name, theme )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
		if not class.typeOf( theme, Theme ) then return error( "expected Theme theme, got " .. class.type( theme ) ) end
	 -- @endif
	self.themes[name] = theme
end

function SMLDocument:getTheme( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.themes[name] or self.themes.default
end

function SMLDocument:addElement( name, cls, decoder )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
		if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
		if not class.typeOf( decoder, SMLNodeDecoder ) then return error( "expected SMLNodeDecoder decoder, got " .. class.type( decoder ) ) end
	 -- @endif
	self.elements[name] = cls
	self.decoders[name] = decoder
end

function SMLDocument:getElement( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.elements[name]
end

function SMLDocument:setDecoder( name, decoder )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
		if not class.typeOf( decoder, SMLNodeDecoder ) then return error( "expected SMLNodeDecoder decoder, got " .. class.type( decoder ) ) end
	 -- @endif
	self.decoders[name] = decoder
end

function SMLDocument:getDecoder( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.decoders[name]
end

function SMLDocument:setVariable( name, value )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	self.environment[name] = value
end

function SMLDocument:getVariable( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.environment[name]
end
