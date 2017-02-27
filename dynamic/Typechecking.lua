
 -- @print including(dynamic.Typechecking)

@ifn DEBUG
	@private
@endif
@class Typechecking {

}

function Typechecking.check_type( ast, state )
	if ast.type == DVALUE_SELF then
		return ast, state.object:type_of(       Sheet ) and Type.sheets.Sheet
		         or state.object:type_of(      Screen ) and Type.sheets.Screen
		 		 or state.object:type_of( Application ) and Type.sheets.Application
				 or error "this really should never happen but just incase here's an error message"

	elseif ast.type == DVALUE_PARENT then
		return ast, state.object:type_of(       Sheet ) and Type.sheets.Sheet_or_Screen
		         or state.object:type_of(      Screen ) and Type.sheets.Application
		 		 or state.object:type_of( Application ) and Type.primitive.null
				 or error "this really should never happen but just incase here's another error message"

	elseif ast.type == DVALUE_CALL then
		return ast, error "TODO: implement calls, idk how but you can do this!"

	elseif ast.type == DVALUE_QUERY or ast.type == DVALUE_DQUERY then
		local src, srctype = Typechecking.check_type( ast.source, state )

		if not (srctype == Type.sheets.Sheet_or_Screen or srctype == Type.sheets.Application) then
			Exception.throw( DynamicValueException.invalid_query_source( srctype, ast.source.position ) )
		end

		ast.source = src

		return ast, Type.sheets.Sheet_or_Screen

	elseif ast.type == DVALUE_STRING then
		return ast, Type.primitive.string

	elseif ast.type == DVALUE_INTEGER then
		return ast, Type.primitive.integer

	elseif ast.type == DVALUE_FLOAT then
		return ast, Type.primitive.number

	elseif ast.type == DVALUE_BOOLEAN then
		return ast, Type.primitive.boolean

	elseif ast.type == DVALUE_INDEX then
		return ast, error "TODO: implement indexes, idk how but you can do this!"

	elseif ast.type == DVALUE_APPLICATION then
		return ast, Type.sheets.Application

	elseif ast.type == DVALUE_IDENTIFIER then
		if state.environment[ast.value] then
			local value = state.environment[ast.value]

			if type( value ) == "table" then
				if value.type then
					return Typechecking.check_type( value, state )
				elseif value.precalculated_type then
					return ast, value.precalculated_type
				end
			end

			local type = Typechecking.resolve_type( value )

			if type == Type.primitive.integer then
				ast = { type = DVALUE_INTEGER, value = tostring( value ) }
			elseif type == Type.primitive.number then
				ast = { type = DVALUE_FLOAT, value = tostring( value ) }
			elseif type == Type.primitive.string then
				ast = { type = DVALUE_STING, value = value }
			elseif type == Type.primitive.boolean then
				ast = { type = DVALUE_BOOLEAN, value = tostring( value ) }
			else
				Exception.throw( DynamicValueException.unsupported_env_type( type, ast.position ) )
			end

			return ast, type

		elseif state.object.values:has( ast.value ) then
			return {
				type = DVALUE_DOTINDEX;
				value = {
					type = DVALUE_SELF;
					position = ast.position;
				};
				index = ast.value;
			}, ValueHandler.properties[ast.value].type

		else
			Exception.throw( DynamicValueException.undefined_reference( ast.value, ast.position ) )

		end

	elseif ast.type == DVALUE_UNEXPR then
		local _ast, type = Typechecking.check_type( ast.value, state )

		ast.value = _ast

		if ast.operator == "#" then
			if not (type == ListType( Type.any ) or type == Type.primitive.string) then
				Exception.throw( DynamicValueException.invalid_type_len( type, ast.position ) )
			end

			type = Type.primitive.integer
		elseif ast.operator == "!" then
			-- any type is fine
		elseif ast.operator == "-" or ast.operator == "+" then
			if not (type == Type.primitive.integer or type == Type.primitive.number) then
				Exception.throw( DynamicValueException.invalid_type_unmp( type, ast.operator, ast.position ) )
			end
		end

		return ast, type

	elseif ast.type == DVALUE_DOTINDEX then
		local _ast, vtype = Typechecking.check_type( ast.value, state )

		ast.value = _ast

		if vtype == (Type.sheets.Sheet_or_Screen / Type.sheets.Application / Type.primitive.null) then
			if ValueHandler.properties[ast.index] then
				return ast, ValueHandler.properties[ast.index].type
			else
				Exception.throw( DynamicValueException.invalid_index_dotindex( ast.index, ast.position ) )
			end
		else
			Exception.throw( DynamicValueException.invalid_type_dotindex( vtype, ast.value.position ) )
		end

	elseif ast.type == DVALUE_PERCENTAGE then
		local term = ast.value
		local ast = state.percentage_ast
		local val

		if term.type == DVALUE_FLOAT or term.type == DVALUE_INTEGER then
			val = { type = DVALUE_FLOAT, value = tostring( tonumber( term.value ) / 100 ) }
		else
			val = { type = DVALUE_BINEXPR, operator = "/", lvalue = term, rvalue = { type = DVALUE_FLOAT, value = 100 } }
		end

		if val.type == DVALUE_FLOAT and val.value == "1" then
			term = ast
		else
			term = { type = DVALUE_BINEXPR, operator = "*", lvalue = ast, rvalue = val }
		end

		return Typechecking.check_type( term, state )

	elseif ast.type == DVALUE_BINEXPR then
		local lvalue_ast, lvalue_type = Typechecking.check_type( ast.lvalue, state )
		local rvalue_ast, rvalue_type = Typechecking.check_type( ast.rvalue, state )

		ast.lvalue = lvalue_ast
		ast.rvalue = rvalue_ast

		if ast.operator == "+" then
			if lvalue_type == Type.primitive.string then
				if not (rvalue_type == Type.primitive.string or rvalue_type == Type.primitive.integer or rvalue_type == Type.primitive.number) then
					ast.lvalue = { type = DVALUE_TOSTRING, position = ast.position, value = lvalue_ast }
				end

				ast.operator = ".."

				return ast, Type.primitive.string
			elseif rvalue_type == Type.primitive.string then
				if not (lvalue_type == Type.primitive.string or lvalue_type == Type.primitive.integer or lvalue_type == Type.primitive.number) then
					ast.rvalue = { type = DVALUE_TOSTRING, position = ast.position, value = rvalue_ast }
				end

				ast.operator = ".."
			elseif lvalue_type == Type.primitive.integer then
				if rvalue_type == Type.primitive.integer then
					return ast, Type.primitive.integer
				elseif rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					Exception.throw( DynamicValueException.invalid_rvalue_type( ast.operator, rvalue_type, Type.primitive.integer / Type.primitive.number, rvalue_ast.position ) )
				end
			elseif lvalue_type == Type.primitive.number then
				if rvalue_type == Type.primitive.integer or rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					Exception.throw( DynamicValueException.invalid_rvalue_type( ast.operator, rvalue_type, Type.primitive.integer / Type.primitive.number, rvalue_ast.position ) )
				end
			else
				Exception.throw( DynamicValueException.invalid_lvalue_type( ast.operator, lvalue_type, Type.primitive.integer / Type.primitive.number, lvalue_ast.position ) )
			end

		elseif ast.operator == "-" or ast.operator == "*" or ast.operator == "^" then
			if lvalue_type == Type.primitive.integer then
				if rvalue_type == Type.primitive.integer then
					return ast, Type.primitive.integer
				elseif rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					Exception.throw( DynamicValueException.invalid_rvalue_type( ast.operator, rvalue_type, Type.primitive.integer / Type.primitive.number, rvalue_ast.position ) )
				end
			elseif lvalue_type == Type.primitive.number then
				if rvalue_type == Type.primitive.integer or rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					Exception.throw( DynamicValueException.invalid_rvalue_type( ast.operator, rvalue_type, Type.primitive.integer / Type.primitive.number, rvalue_ast.position ) )
				end
			else
				Exception.throw( DynamicValueException.invalid_lvalue_type( ast.operator, lvalue_type, Type.primitive.integer / Type.primitive.number, lvalue_ast.position ) )
			end

		elseif ast.operator == "/" then
			if lvalue_type == Type.primitive.integer / Type.primitive.number then
			 	if rvalue_type == Type.primitive.integer / Type.primitive.number then
					return ast, Type.primitive.number
				else
					Exception.throw( DynamicValueException.invalid_rvalue_type( ast.operator, rvalue_type, Type.primitive.integer / Type.primitive.number, rvalue_ast.position ) )
				end
			else
				Exception.throw( DynamicValueException.invalid_lvalue_type( ast.operator, lvalue_type, Type.primitive.integer / Type.primitive.number, lvalue_ast.position ) )
			end

		elseif ast.operator == "%" then
			if lvalue_type == Type.primitive.integer then
				if rvalue_type == Type.primitive.integer then
					return ast, Type.primitive.number
				else
					Exception.throw( DynamicValueException.invalid_rvalue_type( ast.operator, rvalue_type, Type.primitive.integer, rvalue_ast.position ) )
				end
			else
				Exception.throw( DynamicValueException.invalid_lvalue_type( ast.operator, lvalue_type, Type.primitive.integer, lvalue_ast.position ) )
			end

		elseif ast.operator == "and" then
			return ast, rvalue_type / Type.primitive.null

		elseif ast.operator == "or" then
			local tr = { lvalue_type }
			local idx = 1

			while tr[idx] do
				local t = tr[idx]

				if t:type_of( UnionType ) then
					if not (t.lvalue == Type.primitive.null) then
						tr[idx] = t.lvalue
						if not (t.rvalue == Type.primitive.null) then
							table.insert( tr, idx, t.rvalue )
						end
					elseif not (t.rvalue == Type.primitive.null) then
						tr[idx] = t.rvalue
					else
						table.remove( tr, idx )
					end
				else
					idx = idx + 1
				end
			end

			local t = tr[1]

			if t then
				for i = 2, #tr do
					if not (t == tr[i]) then
						t = UnionType( t, tr[i] )
					end
				end

				if not (t == rvalue_type) then
					t = t / rvalue_type
				end

				return ast, t
			else
				return rvalue_ast, rvalue_type
			end

		elseif ast.operator == ">" or ast.operator == "<" or ast.operator == ">=" or ast.operator == "<=" then
			if lvalue_type == Type.primitive.integer / Type.primitive.number then
				if rvalue_type == Type.primitive.integer / Type.primitive.number then
					return ast, Type.primitive.boolean
				else
					Exception.throw( DynamicValueException.invalid_rvalue_type( ast.operator, rvalue_type, Type.primitive.integer / Type.primitive.number, rvalue_ast.position ) )
				end
			else
				Exception.throw( DynamicValueException.invalid_lvalue_type( ast.operator, lvalue_type, Type.primitive.integer / Type.primitive.number, lvalue_ast.position ) )
			end

		elseif ast.operator == "~=" or ast.operator == "==" then
			return ast, type.primitive.boolean

		end

	elseif ast.type == DVALUE_TAG_CHECK then
		local obj, objtype = Typechecking.check_type( ast.value, state )

		ast.value = obj

		if objtype == Type.sheets.Sheet_or_Screen / Type.primitive.null then
			return ast, Type.primitive.boolean
		else
			Exception.throw( DynamicValueException.invalid_tag_object( objtype, ast.value.position ) )
		end

	else
		-- just incase a new dvalue expression type is added
		return error( "Sheets bug: please report '" .. ast.type .. "' dynamic value typechecking not being implemented", 0 )

	end
end

function Typechecking.resolve_type( value )
	local t = type( value )

	if t == "number" then
		return value % 1 == 0 and Type.primitive.integer or Type.primitive.number
	elseif t == "boolean" or t == "string" then
		return Type.primitive[t]
	elseif t == "nil" then
		return Type.primitive.null
	-- potentially add tables here
	else
		return Type.any
	end
end
