
local is_operator = {
	["+"] = true;
	["-"] = true;
	["*"] = true;
	["/"] = true;
	["%"] = true;
	["^"] = true;
	["&"] = true;
	["|"] = true;
	[">"] = true;
	["<"] = true;
	[">="] = true;
	["<="] = true;
	["!="] = true;
	["=="] = true;
}

local op_precedences = {
	["|"] = 0;
	["&"] = 1;
	["!="] = 2;
	["=="] = 2;
	[">"] = 3;
	["<"] = 3;
	[">="] = 3;
	["<="] = 3;
	["+"] = 4;
	["-"] = 4;
	["*"] = 5;
	["/"] = 5;
	["%"] = 5;
	["^"] = 6;
}

local lua_operators = {
	["|"] = "or";
	["&"] = "and";
}

local function parse_name( stream )
	return stream:skip_value( TOKEN_IDENTIFIER )
end

class "DynamicValueParser" {
	stream = nil;
	context = {};
	query_parser = nil;
}

function DynamicValueParser:DynamicValueParser( stream )
	self.stream = stream
	self.context = { { environment = {} } }
	self.query_parser = QueryParser( stream )
end

function DynamicValueParser:set_context( name, value )
	self.context[#self.context][name] = value
end

function DynamicValueParser:push_context()
	local t = {}

	for k, v in pairs( self.context[#self.context] ) do
		t[k] = v
	end

	self.context[#self.context + 1] = t
end

function DynamicValueParser:pop_context()
	self.context[#self.context] = nil
end

function DynamicValueParser:get_context()
	return self.context[#self.context] or {}
end

function DynamicValueParser:parse_primary_expression()
	if self.stream:test( TOKEN_KEYWORD, "self" ) or self.stream:test( TOKEN_KEYWORD, "application" ) or self.stream:test( TOKEN_KEYWORD, "parent" ) or self.stream:test( TOKEN_IDENTIFIER ) then
		local source

		if self.stream:skip( TOKEN_KEYWORD, "self" ) then
			source = { type = DVALUE_SELF }
		elseif self.stream:skip( TOKEN_KEYWORD, "application" ) then
			source = { type = DVALUE_APPLICATION }
		elseif self.stream:skip( TOKEN_KEYWORD, "parent" ) then
			source = { type = DVALUE_PARENT }
		elseif self.stream:test( TOKEN_IDENTIFIER ) then
			source = { type = DVALUE_IDENTIFIER, value = parse_name( self.stream ) }
		end

		if source.type == DVALUE_IDENTIFIER then
			if not self:get_context().environment[source.value] then
				error "TODO: fix this error"
			end
		end

		if self:get_context().enable_queries and self.stream:skip( TOKEN_SYMBOL, "$" ) then
			local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
			local query = self.query_parser:parse_term( true )

			return { type = dynamic and DVALUE_DQUERY or DVALUE_QUERY, query = query, source = source }
		end

		return source
	elseif self.stream:test( TOKEN_INTEGER ) then
		local value = { type = DVALUE_INTEGER, value = self.stream:next().value }

		if self:get_context().enable_percentages and self.stream:skip( TOKEN_SYMBOL, "%" ) then
			value.type = DVALUE_PERCENTAGE
		end

		return value
	elseif self.stream:test( TOKEN_FLOAT ) then
		local value = { type = DVALUE_FLOAT, value = self.stream:next().value }

		if self:get_context().enable_percentages and self.stream:skip( TOKEN_SYMBOL, "%" ) then
			value.type = DVALUE_PERCENTAGE
		end

		return value
	elseif self.stream:test( TOKEN_BOOLEAN ) then
		return { type = DVALUE_BOOLEAN, value = self.stream:next().value }
	elseif self.stream:test( TOKEN_STRING ) then
		return { type = DVALUE_STRING, value = self.stream:next().value }
	elseif self:get_context().enable_queries and self.stream:skip( TOKEN_SYMBOL, "$" ) then
		local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
		local query = self.query_parser:parse_term( true )

		return { type = dynamic and DVALUE_DQUERY or DVALUE_QUERY, query = query, source = { type = DVALUE_APPLICATION } }
	elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
		local expr = self:parse_expression() or error "TODO: fix this error"

		return self.stream:skip( TOKEN_SYMBOL, ")" ) and expr or error "TODO: fix this error"
	end

	return nil
end

function DynamicValueParser:parse_term()
	local operators = {}

	while self.stream:test( TOKEN_SYMBOL, "#" )
	   or self.stream:test( TOKEN_SYMBOL, "!" )
	   or self.stream:test( TOKEN_SYMBOL, "-" )
	   or self.stream:test( TOKEN_SYMBOL, "+" ) do
		operators[#operators + 1] = self.stream:next().value
	end

	local term = self:parse_primary_expression()

	while term do
		if self.stream:skip( TOKEN_SYMBOL, "." ) then
			term = { type = DVALUE_DOTINDEX, value = term, index = parse_name( self.stream ) or error "TODO: fix this error" }
		elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
			local parameters = {}

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
				repeat
					while self.stream:skip( TOKEN_WHITESPACE ) do end
					parameters[#parameters + 1] = self:parse_expression() or error "TODO: fix this error"
					while self.stream:skip( TOKEN_WHITESPACE ) do end
				until not self.stream:skip( TOKEN_SYMBOL, "," )
	
				if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
					error "TODO: fix this error"
				end
			end

			term = { type = DVALUE_CALL, value = term, parameters = parameters }
		elseif self.stream:skip( TOKEN_SYMBOL, "[" ) then
			while self.stream:skip( TOKEN_WHITESPACE ) do end
			local index = self:parse_expression() or error "TODO: fix this error"
			while self.stream:skip( TOKEN_WHITESPACE ) do end

			if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
				error "TODO: fix this error"
			end

			term = { type = DVALUE_INDEX, value = term, index = index }
		else
			break
		end
	end

	for i = #operators, 1, -1 do
		term = { type = DVALUE_UNEXPR, value = term, operator = operators[i] }
	end

	return term
end

function DynamicValueParser:parse_expression()
	local operand_stack = { self:parse_term() }
	local operator_stack = {}
	local precedences = {}

	if #operand_stack == 0 then
		return nil
	end

	while self.stream:skip( TOKEN_WHITESPACE ) do end

	while self.stream:test( TOKEN_SYMBOL ) and is_operator[self.stream:peek().value] do
		local op = self.stream:next().value
		local prec = op_precedences[op]

		while precedences[1] and precedences[#precedences] > prec do
			local rvalue = table.remove( operand_stack, #operand_stack )

			table.remove( precedences, #precedences )

			operand_stack[#operand_stack] = {
				type = DVALUE_BINEXPR;
				operator = table.remove( operator_stack, #operator_stack );
				lvalue = operand_stack[#operand_stack];
				rvalue = rvalue;
			}
		end

		while self.stream:skip( TOKEN_WHITESPACE ) do end

		operand_stack[#operand_stack + 1] = self:parse_term() or error "TODO: fix this"
		operator_stack[#operator_stack + 1] = lua_operators[op] or op
		precedences[#precedences + 1] = prec

		while self.stream:skip( TOKEN_WHITESPACE ) do end
	end

	while precedences[1] do
		local rvalue = table.remove( operand_stack, #operand_stack )

		table.remove( precedences, #precedences )

		operand_stack[#operand_stack] = {
			type = DVALUE_BINEXPR;
			operator = table.remove( operator_stack, #operator_stack );
			lvalue = operand_stack[#operand_stack];
			rvalue = rvalue;
		}
	end

	return operand_stack[1]
end

function DynamicValueParser:add_macro()

end
