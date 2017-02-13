
 -- @once
 -- @print Including sheets.dynamic.Type

class "Type" {
	name = "";
}

class "IntersectionType" extends "Type" {
	lvalue = nil;
	rvalue = nil;
}

class "UnionType" extends "Type" {
	lvalue = nil;
	rvalue = nil;
}

class "ListType" extends "Type" {
	value = nil;
}

class "TableType" extends "Type" {
	index = nil;
	value = nil;
}

function Type:Type( name )
	self.name = name
	self.meta.__add = self.both
	self.meta.__div = self.either
	self.meta.__eq = self.matches
end

function IntersectionType:IntersectionType( lvalue, rvalue )
	self.lvalue = lvalue
	self.rvalue = rvalue

	return self:Type "Intersection"
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

function IntersectionType:tostring()
	return self.lvalue:tostring() .. " & " .. self.rvalue:tostring()
end

function UnionType:tostring()
	return self.lvalue:tostring() .. " | " .. self.rvalue:tostring()
end

function ListType:tostring()
	return self.value:tostring() .. "[]"
end

function TableType:tostring()
	return self.value:tostring() .. "{" .. self.index:tostring() .. "}"
end

function Type:both( other )
	return IntersectionType( self, other )
end

function Type:either( other )
	return UnionType( self, other )
end

function Type:matches( type )
	if type:type_of( UnionType ) then
		return self:matches( type.lvalue ) or self:matches( type.rvalue )
	elseif type:type_of( IntersectionType ) then
		return self:matches( type.lvalue ) and self:matches( type.rvalue )
	elseif type:type_of( ListType ) then
		return self.name == "List" and self.value:matches( type.value )
	elseif type:type_of( TableType ) then
		return self.name == "Table" and self.value:matches( type.value ) and self.index:matches( type.index )
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
