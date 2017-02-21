
 -- @print including(dynamic.Typechecking)

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
			error "TODO: fix this error"
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
					return Typechecking.check_type( value )
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
				error "TODO: fix this error"
			end

			return ast, type

		elseif state.object.values:has( ast.value ) then
			return {
				type = DVALUE_DOTINDEX;
				value = {
					type = DVALUE_SELF;
				};
				index = ast.value;
			}, ValueHandler.properties[ast.value].type

		else
			error "TODO: fix this error"

		end

	elseif ast.type == DVALUE_UNEXPR then
		local _ast, type = Typechecking.check_type( ast.value, state )

		ast.value = _ast

		if ast.operator == "#" then
			if not (type == ListType( Type.any ) or type == Type.primitive.string) then
				error "TODO: fix this error"
			end

			type = Type.primitive.integer
		elseif ast.operator == "!" then
			-- any type is fine
		elseif ast.operator == "-" or ast.operator == "+" then
			if not (type == Type.primitive.integer or type == Type.primitive.number) then
				error "TODO: fix this error"
			end
		end

		return ast, type

	elseif ast.type == DVALUE_DOTINDEX then
		local _ast, vtype = Typechecking.check_type( ast.value, state )

		ast.value = _ast

		if ValueHandler.properties[ast.index] then

			if vtype == (Type.sheets.Sheet_or_Screen / Type.sheets.Application / Type.primitive.null) then
				return ast, ValueHandler.properties[ast.index].type -- do a check for the index
			else
				error "TODO: fix this error"
			end
		else
			error "TODO: fix this error"
		end

		return ast

	elseif ast.type == DVALUE_PERCENTAGE then
		-- TODO: see issue #37

	elseif ast.type == DVALUE_BINEXPR then
		local lvalue_ast, lvalue_type = Typechecking.check_type( ast.lvalue, state )
		local rvalue_ast, rvalue_type = Typechecking.check_type( ast.rvalue, state )

		ast.lvalue = lvalue_ast
		ast.rvalue = rvalue_ast

		if ast.operator == "+" then
			if lvalue_type == Type.primitive.string then
				if not (rvalue_type == Type.primitive.string or rvalue_type == Type.primitive.integer or rvalue_type == Type.primitive.number) then
					-- tostring it
					error "TODO: implement this"
				end

				ast.operator = ".."

				return ast, Type.primitive.string
			elseif rvalue_type == Type.primitive.string then
				if not (lvalue_type == Type.primitive.string or lvalue_type == Type.primitive.integer or lvalue_type == Type.primitive.number) then
					-- tostring it
					error "TODO: implement this"
				end

				ast.operator = ".."
			elseif lvalue_type == Type.primitive.integer then
				if rvalue_type == Type.primitive.integer then
					return ast, Type.primitive.integer
				elseif rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					error "TODO: fix this error"
				end
			elseif lvalue_type == Type.primitive.number then
				if rvalue_type == Type.primitive.integer or rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					error "TODO: fix this error"
				end
			else
				error "TODO: fix this error"
			end

		elseif ast.operator == "-" or ast.operator == "*" or ast.operator == "^" then
			if lvalue_type == Type.primitive.integer then
				if rvalue_type == Type.primitive.integer then
					return ast, Type.primitive.integer
				elseif rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					error "TODO: fix this error"
				end
			elseif lvalue_type == Type.primitive.number then
				if rvalue_type == Type.primitive.integer or rvalue_type == Type.primitive.number then
					return ast, Type.primitive.number
				else
					error "TODO: fix this error"
				end
			else
				error "TODO: fix this error"
			end

		elseif ast.operator == "/" then
			if  lvalue_type == Type.primitive.integer / Type.primitive.number
			and rvalue_type == Type.primitive.integer / Type.primitive.number then
				return ast, Type.primitive.number
			else
				error "TODO: fix this error"
			end

		elseif ast.operator == "%" then
			if lvalue_type == Type.primitive.integer and rvalue_type == Type.primitive.integer then
				return ast, Type.primitive.number
			else
				error "TODO: fix this error"
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
					t = UnionType( t, tr[i] )
				end

				return ast, t / rvalue_type
			else
				return rvalue_ast, rvalue_type
			end

		elseif ast.operator == ">" or ast.operator == "<" or ast.operator == ">=" or ast.operator == "<=" then
			if  lvalue_type == Type.primitive.integer / Type.primitive.number
			and rvalue_type == Type.primitive.integer / Type.primitive.number then
				return Type.primitive.boolean
			else
				error "TODO: fix this error"
			end

		elseif ast.operator == "~=" or ast.operator == "==" then
			return type.primitive.boolean

		end

	elseif ast.type == DVALUE_TAG_CHECK then
		local obj, objtype = Typechecking.check_type( ast.value, state )

		ast.value = obj

		if objtype == Type.sheets.Sheet_or_Screen / Type.primitive.null then
			return ast, Type.primitive.boolean
		else
			error "TODO: fix this error"
		end

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
