
local operator_list = { ["&"] = 1, ["|"] = 0 }

local function parse_name( stream )
	local name = stream:skip_value( TOKEN_IDENTIFIER ) or error( "TODO: fix this error" )

	while stream:skip( TOKEN_SYMBOL, "-" ) do
		name = name .. stream:skip_value( TOKEN_IDENTIFIER ) or error( "TODO: fix this error" )
	end

	return name
end

class "QueryParser" {
	stream = nil;
}

function QueryParser:QueryParser( stream )
	self.stream = stream
end

function QueryParser:parse_term()
	local negation_count, obj = 0

	while self.stream:skip( TOKEN_SYMBOL, "!" ) do
		negation_count = negation_count + 1
	end

	if self.stream:skip( TOKEN_SYMBOL, "#" ) then -- ID
		obj = { type = QUERY_ID, value = parse_name( self.stream ) }
	elseif self.stream:skip( TOKEN_SYMBOL, "." ) then -- tag
		obj = { type = QUERY_TAG, value = parse_name( self.stream ) }
	elseif self.stream:skip( TOKEN_SYMBOL, "*" ) then
		obj = { type = QUERY_ALL }
	-- TODO: QUERY_CLASS
	elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
		print( self.stream:peek().value )
		obj = self:parse_query()

		if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
			error "TODO: fix this error"
		end
	else
		error "TODO: fix this error"
	end

	if self.stream:skip( TOKEN_SYMBOL, "[" ) then
		local attributes = {}

		error "NYI"

		obj = { type = QUERY_ATTRIBUTES, attributes = attributes }
	end

	if negation_count % 2 == 1 then
		obj = { type = QUERY_NEGATE, value = obj }
	end

	return obj
end

function QueryParser:parse_query()
	local operands = { self:parse_term() }
	local operators = {}

	while self.stream:skip( TOKEN_WHITESPACE ) do end

	while self.stream:test( TOKEN_SYMBOL ) do
		local prec = operator_list[self.stream:peek().value]

		if prec then
			while operators[1] and operator_list[operators[#operators]] >= prec do -- assumming left associativity for all operators
				operands[#operands - 1] = {
					type = QUERY_OPERATOR;
					lvalue = operands[#operands - 1];
					rvalue = table.remove( operands, #operands );
					operator = table.remove( operators, #operators );
				}
			end

			operators[#operators + 1] = self.stream:next().value

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			operands[#operands + 1] = self:parse_term()

			while self.stream:skip( TOKEN_WHITESPACE ) do end
		else
			break
		end
	end

	while operators[1] do
		operands[#operands - 1] = {
			type = QUERY_OPERATOR;
			lvalue = operands[#operands - 1];
			rvalue = table.remove( operands, #operands );
			operator = table.remove( operators, #operators );
		}
	end

	return operands[1]
end
