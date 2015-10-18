
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.sml.SMLEnvironment'
 -- @endif

 -- @print Including sheets.sml.SMLEnvironment

class "SMLEnvironment" {
	themes = {};
	scripts = {};
	elements = {};
	decoders = {};
	variables = {
		transparent = TRANSPARENT;
		white = WHITE;
		orange = ORANGE;
		magenta = MAGENTA;
		lightBlue = LIGHTBLUE;
		yellow = YELLOW;
		lime = LIME;
		pink = PINK;
		grey = GREY;
		lightGrey = LIGHTGREY;
		cyan = CYAN;
		purple = PURPLE;
		blue = BLUE;
		brown = BROWN;
		green = GREEN;
		red = RED;
		black = BLACK;
	};
	path = "";
}

function SMLEnvironment.current()
	return Application.active and Application.active.environment or error( "Cannot get current SML environment: no active application", 2 )
end

function SMLEnvironment:SMLEnvironment()
	self.themes = setmetatable( {}, { __index = SMLEnvironment.themes } )
	self.scripts = setmetatable( {}, { __index = SMLEnvironment.scripts } )
	self.elements = setmetatable( {}, { __index = SMLEnvironment.elements } )
	self.decoders = setmetatable( {}, { __index = SMLEnvironment.decoders } )
	self.variables = setmetatable( {}, { __index = SMLEnvironment.variables } )
end

function SMLEnvironment:setTheme( name, theme )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
		if not class.typeOf( theme, Theme ) then return error( "expected Theme theme, got " .. class.type( theme ) ) end
	 -- @endif
	self.themes[name] = theme
end

function SMLEnvironment:getTheme( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.themes[name]
end

function SMLEnvironment:setScript( name, script )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
		if type( script ) ~= "function" then return error( "expected function script, got " .. class.type( script ) ) end
	 -- @endif
	self.scripts[name] = script
end

function SMLEnvironment:getScript( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.scripts[name]
end

function SMLEnvironment:addElement( name, cls, decoder )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
		if not class.isClass( cls ) then return error( "expected Class class, got " .. class.type( cls ) ) end
		if not class.typeOf( decoder, SMLNodeDecoder ) then return error( "expected SMLNodeDecoder decoder, got " .. class.type( decoder ) ) end
	 -- @endif
	self.elements[name] = cls
	self.decoders[name] = decoder
end

function SMLEnvironment:getElement( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.elements[name]
end

function SMLEnvironment:setDecoder( name, decoder )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
		if not class.typeOf( decoder, SMLNodeDecoder ) then return error( "expected SMLNodeDecoder decoder, got " .. class.type( decoder ) ) end
	 -- @endif
	self.decoders[name] = decoder
end

function SMLEnvironment:getDecoder( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.decoders[name]
end

function SMLEnvironment:setVariable( name, value )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	self.variables[name] = value
end

function SMLEnvironment:getVariable( name )
	 -- @if SHEETS_TYPE_CHECK
		if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end
	 -- @endif
	return self.variables[name]
end
