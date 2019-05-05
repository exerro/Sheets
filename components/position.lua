
 -- @include component

local centrex = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="50"}},rvalue={type=DVALUE_BINEXPR,operator="/",lvalue={type=DVALUE_IDENTIFIER,value= "width"},rvalue={type=DVALUE_INTEGER,value="2"}}}
local centrey = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="50"}},rvalue={type=DVALUE_BINEXPR,operator="/",lvalue={type=DVALUE_IDENTIFIER,value="height"},rvalue={type=DVALUE_INTEGER,value="2"}}}

COMPONENT(position) {
	PROPERTY(x, 0) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='width'});
		custom_value_modification_code = "if value > self.max_x then\nvalue = self.max_x\nend\nif value < self.min_x then\nvalue = self.min_x\nend";
	};
	ENVIRONMENT(x) {
		left = 0;
		out_left={type=DVALUE_UNEXPR,operator="-",value={type=DVALUE_IDENTIFIER,value="width"}};
		centre = centrex;
		center = centrex;
		right={type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="width"}};
		out_right={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}};
	};
	PROPERTY(min-x, -math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='width'});
		custom_update_code = "if self.x < self.min_x then\nself:set_x( self.min_x )\nend";
	};
	ENVIRONMENT(min-x) {
		none = -math.huge;
	};
	PROPERTY(max-x, math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='width'});
		custom_update_code = "if self.x > self.max_x then\nself:set_x( self.max_x )\nend";
	};
	ENVIRONMENT(max-x) {
		none = math.huge;
	};
	PROPERTY(y, 0) {
		custom_value_modification_code = "if value > self.max_y then\nvalue = self.max_y\nend\nif value < self.min_y then\nvalue = self.min_y\nend";
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
	PROPERTY(min-y, -math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='height'});
		custom_update_code = "if self.y < self.min_y then\nself:set_y( self.min_y )\nend";
	};
	ENVIRONMENT(min-y) {
		none = -math.huge;
	};
	PROPERTY(max-y, math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='height'});
		custom_update_code = "if self.y > self.max_y then\nself:set_y( self.max_y )\nend";
	};
	ENVIRONMENT(max-y) {
		none = math.huge;
	};
	PROPERTY(z, 0) {
		custom_update_code = "if self.parent then self.parent:reposition_child_z_index( self ) end";
	};
}
