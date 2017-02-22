
 -- @include component

local centrex = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="50"}},rvalue={type=DVALUE_BINEXPR,operator="/",lvalue={type=DVALUE_IDENTIFIER,value= "width"},rvalue={type=DVALUE_INTEGER,value="2"}}}
local centrey = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="50"}},rvalue={type=DVALUE_BINEXPR,operator="/",lvalue={type=DVALUE_IDENTIFIER,value="height"},rvalue={type=DVALUE_INTEGER,value="2"}}}

COMPONENT(position) {
	PROPERTY(x, 0) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='width'});
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
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='height'});
	};
	ENVIRONMENT(y) {
		top = 0;
		out_top={type=DVALUE_UNEXPR,operator="-",value={type=DVALUE_IDENTIFIER,value="height"}};
		centre = centrey;
		center = centrey;
		bottom={type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="height"}};
		out_bottom={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}};
	};
	PROPERTY(z, 0) {
		custom_update_code = "if self.parent then self.parent:reposition_child_z_index( self ) end";
	};
}
