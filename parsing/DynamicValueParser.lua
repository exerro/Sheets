
local function parse_name( stream )
	local name = stream:skip_value( TOKEN_IDENTIFIER )
end

class "DynamicValueParser" {
	stream = nil;
}

function DynamicValueParser:DynamicValueParser( stream )
	self.stream = stream
end

function DynamicValueParser:add_macro()

end
