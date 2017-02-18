
 -- @once
 -- @print Including sheets.dynamic.DynamicValueParser

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
	["!="] = "~=";
}

local function parse_name( stream )
	return stream:skip_value( TOKEN_IDENTIFIER )
end

class "DynamicValueParser" {
	stream = nil;
	flags = {};
}

function DynamicValueParser:DynamicValueParser( stream )
	self.stream = stream
	self.flags = {}
end

function DynamicValueParser:parse_primary_expression()
	if self.stream:skip( TOKEN_KEYWORD, "self" ) then
		return { type = DVALUE_SELF }

	elseif self.stream:skip( TOKEN_KEYWORD, "application" ) then
		return { type = DVALUE_APPLICATION }

	elseif self.stream:skip( TOKEN_KEYWORD, "parent" ) then
		return { type = DVALUE_PARENT }

	elseif self.stream:test( TOKEN_IDENTIFIER ) then
		return { type = DVALUE_IDENTIFIER, value = parse_name( self.stream ) }

	elseif self.stream:test( TOKEN_INTEGER ) then
		return { type = DVALUE_INTEGER, value = self.stream:next().value }

	elseif self.stream:test( TOKEN_FLOAT ) then
		return { type = DVALUE_FLOAT, value = self.stream:next().value }

	elseif self.stream:test( TOKEN_BOOLEAN ) then
		return { type = DVALUE_BOOLEAN, value = self.stream:next().value }
	elseif self.stream:test( TOKEN_STRING ) then
		return { type = DVALUE_STRING, value = self.stream:next().value }
	elseif self.stream:test( TOKEN_SYMBOL, "$" ) then
		if self.flags.enable_queries then
			self.stream:next()
		else
			error "TODO: fix this error"
		end

		local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
		local query = self:parse_query_term( true )

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
			local index = parse_name( self.stream )
			           or self.stream:skip_value( TOKEN_KEYWORD, "parent" )
		   			   or self.stream:skip_value( TOKEN_KEYWORD, "application" )
			           or error "TODO: fix this error"
			term = { type = DVALUE_DOTINDEX, value = term, index = index }

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

			if not self.stream:skip( TOKEN_SYMBOL, "]" ) then
				error "TODO: fix this error"
			end

			term = { type = DVALUE_INDEX, value = term, index = index }

		elseif self.stream:test( TOKEN_SYMBOL, "$" ) then
			if self.flags.enable_queries then
				self.stream:next()
			else
				error "TODO: fix this error"
			end

			local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
			local query = self:parse_query_term( true )

			term = { type = dynamic and DVALUE_DQUERY or DVALUE_QUERY, query = query, source = term }
		elseif self.stream:test( TOKEN_SYMBOL, "%" ) then
			if self.flags.enable_percentages then
				self.stream:next()
			else
				error "TODO: fix this error"
			end

			term = { type = DVALUE_PERCENTAGE, value = term }
		else
			break
		end
	end

	for i = #operators, 1, -1 do
		term = term and { type = DVALUE_UNEXPR, value = term, operator = operators[i] }
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

		while precedences[1] and precedences[#precedences] >= prec do
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

function DynamicValueParser:parse_query_term( in_dynamic_value )
	local negation_count, obj = 0

	while self.stream:skip( TOKEN_SYMBOL, "!" ) do
		negation_count = negation_count + 1
	end

	if self.stream:test( TOKEN_IDENTIFIER ) or self.stream:skip( TOKEN_SYMBOL, "#" ) then -- ID
		obj = { type = QUERY_ID, value = parse_name( self.stream ) or error "TODO: fix this error" }
		ID_parsed = true
	elseif self.stream:skip( TOKEN_SYMBOL, "*" ) then
		obj = { type = QUERY_ANY }
	elseif self.stream:skip( TOKEN_SYMBOL, "?" ) then
		obj = { type = QUERY_CLASS, value = parse_name( self.stream ) or error "TODO: fix this error" }
	elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
		print( self.stream:peek().value )
		obj = self:parse_query()

		if not self.stream:skip( TOKEN_SYMBOL, ")" ) then
			error "TODO: fix this error"
		end
	end

	local tags = {}

	while (not in_dynamic_value or not obj) and self.stream:skip( TOKEN_SYMBOL, "." ) do -- tags
		local tag = { type = QUERY_TAG, value = parse_name( self.stream ) or error "TODO: fix this error" }

		if obj then
			obj = { type = QUERY_OPERATOR, operator = "&", lvalue = obj, rvalue = tag }
		else
			obj = tag
		end
	end

	if self.stream:skip( TOKEN_SYMBOL, "[" ) then
		local attributes = {}

		repeat
			local name = parse_name( self.stream ) or error "TODO: fix this error"

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local comparison
			    = self.stream:skip_value( TOKEN_SYMBOL, "=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, ">" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "<" )
			   or self.stream:skip_value( TOKEN_SYMBOL, ">=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "<=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "!=" )
			   or error "TODO: fix this"

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local value = self:parse_expression() or error "TODO: fix this error"

			attributes[#attributes + 1] = {
				name = name;
				comparison = comparison;
				value = value;
			}
		until not self.stream:skip( TOKEN_SYMBOL, "," )

		if not self.stream:skip( TOKEN_SYMBOL, "]" ) then
			error "TODO: fix this error"
		end

		obj = obj and {
			type = QUERY_OPERATOR;
			rvalue = obj;
			lvalue = { type = QUERY_ATTRIBUTES, attributes = attributes };
			operator = "&";
		} or { type = QUERY_ATTRIBUTES, attributes = attributes }
	end

	if not obj then
		error "TODO: fix this error"
	end

	if negation_count % 2 == 1 then
		obj = { type = QUERY_NEGATE, value = obj }
	end

	return obj
end

function DynamicValueParser:parse_query( in_dynamic_value )
	local operands = { self:parse_query_term( in_dynamic_value ) }
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

			operands[#operands + 1] = self:parse_query_term( in_dynamic_value )

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
