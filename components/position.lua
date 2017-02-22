
 -- @include component

local centrex = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="50"}},rvalue={type=DVALUE_BINEXPR,operator="/",lvalue={type=DVALUE_IDENTIFIER,value= "width"},rvalue={type=DVALUE_INTEGER,value="2"}}}
local centrey = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="50"}},rvalue={type=DVALUE_BINEXPR,operator="/",lvalue={type=DVALUE_IDENTIFIER,value="height"},rvalue={type=DVALUE_INTEGER,value="2"}}}

COMPONENT(position) {
	PROPERTY(x, 0) {
		-- enable percentages
		percentage_ast = x_percentage_ast;
	};
	ENVIRONMENT(x) {
		left = 0;
		out_left={type=DVALUE_UNEXPR,operator="-",value={type=DVALUE_IDENTIFIER,value="width"}};
		centre = centrex;
		center = centrex;
		right={type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="width"}};
		out_right={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}};
	};
	PROPERTY(y, 0) {
		-- enable percentages
	};
	ENVIRONMENT(y) {
		left = 0;
		out_left={type=DVALUE_UNEXPR,operator="-",value={type=DVALUE_IDENTIFIER,value="height"}};
		centre = centrey;
		center = centrey;
		right={type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="height"}};
		out_right={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}};
	};
	PROPERTY(z, 0) {
		custom_update_code = "if self.parent then self.parent:reposition_child_z_index( self ) end";
	};
}
