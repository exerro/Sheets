
 -- @include exceptions.DynamicParserException

 -- @print including(dynamic.DynamicValueParser)

local query_operator_list = { ["&"] = 1, ["|"] = 0, [">"] = 2 }

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

@ifn DEBUG
	@private
@endif
@class DynamicValueParser {
	stream = nil;
	flags = {};
}

function DynamicValueParser:DynamicValueParser( stream )
	self.stream = stream
	self.flags = {}
end

function DynamicValueParser:parse_primary_expression()
	local position = self.stream:peek().position

	if self.stream:skip( TOKEN_KEYWORD, "self" ) then
		return { type = DVALUE_SELF, position = position }

	elseif self.stream:skip( TOKEN_KEYWORD, "application" ) then
		return { type = DVALUE_APPLICATION, position = position }

	elseif self.stream:skip( TOKEN_KEYWORD, "parent" ) then
		return { type = DVALUE_PARENT, position = position }

	elseif self.stream:test( TOKEN_IDENTIFIER ) then
		return { type = DVALUE_IDENTIFIER, value = parse_name( self.stream ), position = position }

	elseif self.stream:test( TOKEN_INTEGER ) then
		return { type = DVALUE_INTEGER, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_FLOAT ) then
		return { type = DVALUE_FLOAT, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_BOOLEAN ) then
		return { type = DVALUE_BOOLEAN, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_STRING ) then
		return { type = DVALUE_STRING, value = self.stream:next().value, position = position }

	elseif self.stream:test( TOKEN_SYMBOL, "$" ) then
		if self.flags.enable_queries then
			self.stream:next()
		else
			Exception.throw( DynamicParserException.disabled_queries( self.stream:peek().position ) )
		end

		local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
		local query = self:parse_query_term( true )

		return { type = dynamic and DVALUE_DQUERY or DVALUE_QUERY, query = query, source = { type = DVALUE_APPLICATION }, position = position }
	elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
		local expr = self:parse_expression()
			or Exception.throw( DynamicParserException.expected_expression( "after '('", self.stream:peek().position ) )

		return self.stream:skip( TOKEN_SYMBOL, ")" ) and expr
			or Exception.throw( DynamicParserException.expected_closing( ")", self.stream:peek().position ) )
	end

	return nil
end

function DynamicValueParser:parse_term()
	local operators = {}
	local op_positions = {}

	while self.stream:test( TOKEN_SYMBOL, "#" )
	   or self.stream:test( TOKEN_SYMBOL, "!" )
	   or self.stream:test( TOKEN_SYMBOL, "-" )
	   or self.stream:test( TOKEN_SYMBOL, "+" ) do
		op_positions[#op_positions + 1] = self.stream:peek().position
		operators[#operators + 1] = self.stream:next().value
	end

	local term = self:parse_primary_expression()

	while term do
		if self.stream:skip( TOKEN_SYMBOL, "." ) then
			local index = self.stream:skip( TOKEN_IDENTIFIER )
			           or self.stream:skip( TOKEN_KEYWORD, "parent" )
		   			   or self.stream:skip( TOKEN_KEYWORD, "application" )
			           or Exception.throw( DynamicParserException.invalid_dotindex( self.stream:peek() ) )
			local pos = { source = term.position.source, lines = term.position.lines;
		 		start = term.position.start, finish = index.position.finish }

			term = { type = DVALUE_DOTINDEX, value = term, index = index.value, position = pos }

		elseif self.stream:skip( TOKEN_SYMBOL, "#" ) then
			local tag = self.stream:skip( TOKEN_IDENTIFIER )
			         or self.stream:skip( TOKEN_KEYWORD )
					 or Exception.throw( DynamicParserException.invalid_tagname( self.stream:peek() ) )
			local pos = { source = term.position.source, lines = term.position.lines;
				start = term.position.start, finish = tag.position.finish }

			term = { type = DVALUE_TAG_CHECK, value = term, tag = tag.value, position = pos }

		elseif self.stream:skip( TOKEN_SYMBOL, "(" ) then
			local parameters = {}
			local closing_brace

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			closing_brace = self.stream:skip( TOKEN_SYMBOL, ")" )

			if not closing_brace then
				repeat
					while self.stream:skip( TOKEN_WHITESPACE ) do end
					parameters[#parameters + 1] = self:parse_expression()
						or Exception.throw( DynamicParserException.expected_expression( "for function parameter", self.stream:peek().position ) )
					while self.stream:skip( TOKEN_WHITESPACE ) do end
				until not self.stream:skip( TOKEN_SYMBOL, "," )

				closing_brace = self.stream:skip( TOKEN_SYMBOL, ")" )

				if not closing_brace then
					Exception.throw( DynamicParserException.expected_closing( ")", self.stream:peek().position ) )
				end
			end

			local pos = { source = term.position.source, lines = term.position.lines;
				start = term.position.start, finish = closing_brace.position.finish }

			term = { type = DVALUE_CALL, value = term, parameters = parameters, position = pos }

		elseif self.stream:skip( TOKEN_SYMBOL, "[" ) then
			local closing_brace
			while self.stream:skip( TOKEN_WHITESPACE ) do end
			local index = self:parse_expression() or Exception.throw( DynamicParserException.expected_expression( "for index", self.stream:peek().position ) )
			while self.stream:skip( TOKEN_WHITESPACE ) do end

			closing_brace = self.stream:skip( TOKEN_SYMBOL, "]" )

			if not closing_brace then
				Exception.throw( DynamicParserException.expected_closing( "]", self.stream:peek().position ) )
			end

			local pos = { source = term.position.source, lines = term.position.lines;
				start = term.position.start, finish = closing_brace.position.finish }

			term = { type = DVALUE_INDEX, value = term, index = index, position = pos }

		elseif self.stream:test( TOKEN_SYMBOL, "$" ) then
			if self.flags.enable_queries then
				self.stream:next()
			else
				Exception.throw( DynamicParserException.disabled_queries( self.stream:peek().position ) )
			end

			local dynamic = not self.stream:skip( TOKEN_SYMBOL, "$" )
			local query = self:parse_query_term( true )
			local pos = { source = term.position.source, lines = term.position.lines;
				start = term.position.start, finish = query.position.finish }

			term = { type = dynamic and DVALUE_DQUERY or DVALUE_QUERY, query = query, source = term, position = pos }
		elseif self.stream:test( TOKEN_SYMBOL, "%" ) then
			if self.flags.enable_percentages then
				local percent = self.stream:next()
				local pos = { source = term.position.source, lines = term.position.lines;
					start = term.position.start, finish = percent.position.finish }

				term = { type = DVALUE_PERCENTAGE, value = term, position = pos }
			else
				Exception.throw( DynamicParserException.disabled_percentages( self.stream:peek().position ) )
			end
		else
			break
		end
	end

	if not term and #operators > 0 then
		Exception.throw( DynamicParserException.expected_expression( "after unary operator '" .. operators[#operators] .. "'", self.stream:peek().position ) )
	end

	for i = #operators, 1, -1 do
		term = term and { type = DVALUE_UNEXPR, value = term, operator = operators[i], position = {
			source = term.position.source, lines = term.position.lines;
			start = op_positions[i].start, finish = term.position.finish } }
	end

	return term
end

function DynamicValueParser:parse_expression()
	local operand_stack = { self:parse_term() }
	local operator_stack = {}
	local precedences = {}
	local positions = {}

	if #operand_stack == 0 then
		return nil
	end

	while self.stream:skip( TOKEN_WHITESPACE ) do end

	while self.stream:test( TOKEN_SYMBOL ) and is_operator[self.stream:peek().value] do
		local pos = self.stream:peek().position
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
				position = { source = rvalue.position.source, lines = rvalue.position.lines;
					start = operand_stack[#operand_stack].position.start, finish = rvalue.position.finish };
			}
		end

		while self.stream:skip( TOKEN_WHITESPACE ) do end

		operand_stack[#operand_stack + 1] = self:parse_term()
			or Exception.throw( DynamicParserException.expected_expression( "after binary operator '" .. op .. "'", pos ) )
		operator_stack[#operator_stack + 1] = lua_operators[op] or op
		precedences[#precedences + 1] = prec
		positions[#positions + 1] = pos

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
			position = { source = rvalue.position.source, lines = rvalue.position.lines;
				start = operand_stack[#operand_stack].position.start, finish = rvalue.position.finish };
		}
	end

	return operand_stack[1]
end

function DynamicValueParser:parse_query_term( in_dynamic_value )
	local negation_count, obj = 0
	local start_position = self.stream:peek().position

	while self.stream:skip( TOKEN_SYMBOL, "!" ) do
		negation_count = negation_count + 1
	end

	if self.stream:test( TOKEN_IDENTIFIER ) then -- ID
		local pos = self.stream:peek().position
		local name = self.stream:next().value

		if self.stream:skip( TOKEN_SYMBOL, "?" ) then
			obj = { type = QUERY_CLASS, value = name, position = pos }
			self.stream:skip( TOKEN_WHITESPACE )
		else
			obj = { type = QUERY_ID, value = name, position = pos }
		end
	elseif self.stream:test( TOKEN_SYMBOL, "*" ) then
		obj = { type = QUERY_ANY, position = self.stream:next().position }
	elseif self.stream:test( TOKEN_SYMBOL, "(" ) then
		local spos = self.stream:next().position

		obj = self:parse_query()

		if not self.stream:test( TOKEN_SYMBOL, ")" ) then
			Exception.throw( DynamicParserException.expected_closing( ")", self.stream:skip().position ) )
		end

		obj.position = {
			source = spos.source, lines = spos.lines;
			start = spos.start, finish = self.stream:next().position.finish
		}
	end

	local tags = {}

	while (not in_dynamic_value or not obj) and self.stream:test( TOKEN_SYMBOL, "#" ) do -- tags
		local spos = self.stream:next().position
		local tag_token = self.stream:skip( TOKEN_IDENTIFIER )
		               or self.stream:skip( TOKEN_KEYWORD )
					   or Exception.throw( DynamicParserException.invalid_tagname( self.stream:peek() ) )
		local tag = { type = QUERY_TAG, value = tag_token.value, position = {
			source = spos.source, lines = spos.lines;
			start = spos.start, finish = tag_token.position.finish;
		} }

		if obj then
			obj = { type = QUERY_OPERATOR, operator = "&", lvalue = obj, rvalue = tag, position = {
				source = tag.position.source, lines = tag.position.lines;
				start = obj.position.start, finish = tag.position.finish;
			} }
		else
			obj = tag
		end

		self.stream:skip( TOKEN_WHITESPACE )
	end

	if self.stream:test( TOKEN_SYMBOL, "[" ) then
		local spos = self.stream:next().position
		local attributes = {}

		repeat
			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local name = parse_name( self.stream ) or Exception.throw( DynamicParserException.invalid_property( self.stream:peek() ) )

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local comparison
			    = self.stream:skip_value( TOKEN_SYMBOL, "=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, ">" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "<" )
			   or self.stream:skip_value( TOKEN_SYMBOL, ">=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "<=" )
			   or self.stream:skip_value( TOKEN_SYMBOL, "!=" )
			   or Exception.throw( DynamicParserException.invalid_comparison( self.stream:peek().position ) )

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			local value = self:parse_expression() or Exception.throw( DynamicParserException.expected_expression( "after comparison '" .. comparison .. "'", self.stream:peek().position ) )

			while self.stream:skip( TOKEN_WHITESPACE ) do end

			attributes[#attributes + 1] = {
				name = name;
				comparison = comparison;
				value = value;
			}
		until not self.stream:skip( TOKEN_SYMBOL, "," )

		while self.stream:skip( TOKEN_WHITESPACE ) do end

		if not self.stream:test( TOKEN_SYMBOL, "]" ) then
			Exception.throw( DynamicParserException.expected_closing( "]", self.stream:peek().position ) )
		end

		obj = obj and {
			type = QUERY_OPERATOR;
			rvalue = obj;
			lvalue = { type = QUERY_ATTRIBUTES, attributes = attributes };
			operator = "&";
			position = {
				source = spos.source, lines = spos.lines;
				start = spos, finish = self.stream:next().position.finish;
			}
		} or { type = QUERY_ATTRIBUTES, attributes = attributes }
	end

	if not obj then
		Exception.throw( DynamicParserException.expected_query_term( self.stream:peek().position ) )
	end

	if negation_count % 2 == 1 then
		obj = { type = QUERY_NEGATE, value = obj, position = {
			source = start_position.source, lines = start_position.lines;
			start = start_position, finish = obj.position.finish;
		} }
	else
		obj.position.start = start_position;
	end

	return obj
end

function DynamicValueParser:parse_query( in_dynamic_value )
	local operands = { self:parse_query_term( in_dynamic_value ) }
	local operators = {}

	while self.stream:skip( TOKEN_WHITESPACE ) do end

	while self.stream:test( TOKEN_SYMBOL ) do
		local prec = query_operator_list[self.stream:peek().value]

		if prec then
			while operators[1] and query_operator_list[operators[#operators]] >= prec do -- assumming left associativity for all operators
				local lvalue = operands[#operands - 1]
				local rvalue = table.remove( operands, #operands )

				operands[#operands - 1] = {
					type = QUERY_OPERATOR;
					lvalue = lvalue;
					rvalue = rvalue;
					operator = table.remove( operators, #operators );
					position = {
						source = lvalue.position.source, lines = lvalue.position.lines;
						start = lvalue.position.start, finish = rvalue.position.finish;
					}
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
		local lvalue = operands[#operands - 1]
		local rvalue = table.remove( operands, #operands )

		operands[#operands - 1] = {
			type = QUERY_OPERATOR;
			lvalue = lvalue;
			rvalue = rvalue;
			operator = table.remove( operators, #operators );
			position = {
				source = lvalue.position.source, lines = lvalue.position.lines;
				start = lvalue.position.start, finish = rvalue.position.finish;
			}
		}
	end

	return operands[1]
end
