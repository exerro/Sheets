
 -- @print including(dynamic.Type)

@private
@class Type {
	name = "";
}

@private
@class UnionType extends Type {
	lvalue = nil;
	rvalue = nil;
}

@private
@class ListType extends Type {
	value = nil;
}

@private
@class TableType extends Type {
	index = nil;
	value = nil;
}

function Type:Type( name )
	self.name = name
	self.meta.__div = self.either
	self.meta.__eq = self.matches
end

function UnionType:UnionType( lvalue, rvalue )
	self.lvalue = lvalue
	self.rvalue = rvalue

	return self:Type "Union"
end

function ListType:ListType( value )
	self.value = value

	return self:Type "List"
end

function TableType:TableType( index, value )
	self.index = index
	self.value = value

	return self:Type "Table"
end

function Type:tostring()
	return self.name
end

function UnionType:tostring()
	return self.lvalue:tostring() .. "|" .. self.rvalue:tostring()
end

function ListType:tostring()
	return self.value:tostring() .. "[]"
end

function TableType:tostring()
	return self.value:tostring() .. "{" .. self.index:tostring() .. "}"
end

function Type:either( other )
	return UnionType( self, other )
end

function Type:matches( type )
	if self:type_of( UnionType ) then
		return self.lvalue:matches( type ) and self.rvalue:matches( type )
	elseif type:type_of( UnionType ) then
		return self:matches( type.lvalue ) or self:matches( type.rvalue )
	elseif type:type_of( ListType ) then
		return self.name == "List" and self.value:matches( type.value )
	elseif type:type_of( TableType ) then
		return self.name == "Table" and self.value:matches( type.value ) and self.index:matches( type.index )
	elseif type.name == "Any" then
		return true
	else
		return self.name == type.name
	end
end

Type.primitive = {}
Type.primitive.null = Type "Null"
Type.primitive.integer = Type "Integer"
Type.primitive.number = Type "Number"
Type.primitive.string = Type "String"
Type.primitive.boolean = Type "Boolean"
Type.primitive.optional_integer = Type.primitive.integer / Type.primitive.null
Type.primitive.optional_number = Type.primitive.number / Type.primitive.null
Type.primitive.optional_string = Type.primitive.string / Type.primitive.null
Type.primitive.optional_boolean = Type.primitive.boolean / Type.primitive.null

Type.any = Type "Any"

Type.sheets = {}
Type.sheets.colour = Type "colour"
Type.sheets.alignment = Type "alignment"
Type.sheets.Sheet = Type "Sheet"
Type.sheets.optional_Sheet = Type "Sheet" / Type.primitive.null
Type.sheets.Screen = Type "Screen"
Type.sheets.Application = Type "Application"
Type.sheets.Sheet_or_Screen = Type.sheets.Sheet / Type.sheets.Screen
