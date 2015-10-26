
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

local function parseScript( script, name )
	return pcall( function()
		local parser = SMLParser( script )
		parser:begin()
		return parser:parseBody()
	end )
end

local function readScript( file )
	local h = fs.open( file, "r" )
	if h then
		local content = h.readAll()
		h.close()
		return parseScript( content, fs.getName( file ) )
	else
		return false, "failed to open file '" .. file .. "'"
	end
end

local function rawLoadNode( self, node, parent )
	local decoder = self:getDecoder( node.nodetype )
	if decoder then
		local src = node:get "src"
		if src then
			if node.body then
				return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: cannot have src attribute and body", 0 )
			elseif type( src ) ~= "string" then
				return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: expected string 'src'", 0 )
			else
				local ok, data = readScript( self.application and self.application.path .. "/" .. src or src )
				if ok then
					node.body = data
				else
					return false, data
				end
			end
		end

		if node.body and not decoder.isBodyAllowed then
			return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: body not allowed for node '" .. decoder.name .. "'", 0 )
		elseif not node.body and decoder.isBodyNecessary then
			return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: body required for node '" .. decoder.name .. "'", 0 )
		end

		local element = decoder:init( parent )

		for i = 1, #node.attributes do
			local k, v = node.attributes[i][1], node.attributes[i][2]
			if k ~= "src" then
				if decoder["attribute_" .. k] then
					local ok, data = pcall( decoder["attribute_" .. k], element, v, node, parent )
					if not ok then
						return false, data
					end
				else
					return error( "[" .. node.position.line .. ", " .. node.position.character .. "]: invalid attribute '" .. k .. "' for node '" .. decoder.name .. "'", 0 )
				end
			end
		end

		if node.body then
			local ok, data = pcall( decoder.decodeBody, element, node.body, parent )
			if not ok then
				return false, data
			end
		end

		return element
	else
		return false, "[" .. node.position.line .. ", " .. node.position.character .. "]: unknown node type '" .. node.nodetype .. "'"
	end
end

class "SMLDocument" {
	themes = {};
	environment = { application = application };
	decoders = {};
	elements = {};
}

function SMLDocument.current()
	return active
end

function SMLDocument:SMLDocument()
	self.themes = copyt( SMLDocument.themes )
	self.environment = copyt( SMLDocument.environment )
	self.decoders = copyt( SMLDocument.decoders )
	self.elements = copyt( SMLDocument.elements )

	self.environment.document = self

	active = self
end

function SMLDocument:loadSMLNode( node, parent )
	if not class.typeOf( node, SMLNode ) then return error( "expected SMLNode node, got " .. class.type( node ) ) end

	active = self
	if not self.application then
		return error( "SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()" )
	end
	return rawLoadNode( self, node, parent )
end

function SMLDocument:loadSMLScript( script, name, parent )
	name = name or "sml-script"

	if type( script ) ~= "string" then return error( "expected string script, got " .. class.type( script ) ) end
	if type( name ) ~= "string" then return error( "expected string source, got " .. class.type( name ) ) end

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
			t[i] = object
		end
		return t
	else
		return false, name .. " " .. data
	end
end

function SMLDocument:loadSMLFile( file, parent )
	if type( file ) ~= "string" then return error( "expected string file, got " .. class.type( file ) ) end

	if not self.application then
		return error( "SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()" )
	end
	local h = fs.open( self.application.path .. "/" .. file, "r" )
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
	if type( script ) ~= "string" then return error( "expected string script, got " .. class.type( script ) ) end
	if type( name ) ~= "string" then return error( "expected string source, got " .. class.type( name ) ) end

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
	if type( file ) ~= "string" then return error( "expected string file, got " .. class.type( file ) ) end

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
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	if not class.typeOf( theme, Theme ) then return error( "expected Theme theme, got " .. class.type( theme ) ) end

	self.themes[name] = theme
end

function SMLDocument:getTheme( name )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end

	return self.themes[name] or self.themes.default
end

function SMLDocument:addElement( name, cls, decoder )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
	if not class.typeOf( decoder, SMLNodeDecoder ) then return error( "expected SMLNodeDecoder decoder, got " .. class.type( decoder ) ) end

	self.elements[name] = cls
	self.decoders[name] = decoder
end

function SMLDocument:getElement( name )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	
	return self.elements[name]
end

function SMLDocument:setDecoder( name, decoder )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	if not class.typeOf( decoder, SMLNodeDecoder ) then return error( "expected SMLNodeDecoder decoder, got " .. class.type( decoder ) ) end
	
	self.decoders[name] = decoder
end

function SMLDocument:getDecoder( name )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	
	return self.decoders[name]
end

function SMLDocument:setVariable( name, value )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	
	self.environment[name] = value
end

function SMLDocument:getVariable( name )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	
	return self.environment[name]
end
