
 -- @include component

COMPONENT(size) {
	PROPERTY(width, 0) {
		update_surface_size = true;
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index="width"});
		custom_value_modification_code = "if value > self.max_width then\nvalue = self.max_width\nend\nif value < self.min_width then\nvalue = self.min_width\nend";
	};
	ENVIRONMENT(width) {
		expand = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="x"}}
	};
	PROPERTY(min-width, -math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='width'});
		custom_update_code = "if self.width < self.min_width then\nself:set_width( self.min_width )\nend";
	};
	ENVIRONMENT(min-width) {
		none = -math.huge;
	};
	PROPERTY(max-width, math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='width'});
		custom_update_code = "if self.width > self.max_width then\nself:set_width( self.max_width )\nend";
	};
	ENVIRONMENT(max-width) {
		none = math.huge;
	};
	PROPERTY(height, 0) {
		update_surface_size = true;
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index="height"});
		custom_value_modification_code = "if value > self.max_height then\nvalue = self.max_height\nend\nif value < self.min_height then\nvalue = self.min_height\nend";
	};
	ENVIRONMENT(height) {
		expand = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="y"}}
	};
	PROPERTY(min-height, -math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='height'});
		custom_update_code = "if self.height < self.min_height then\nself:set_height( self.min_height )\nend";
	};
	ENVIRONMENT(min-height) {
		none = -math.huge;
	};
	PROPERTY(max-height, math.huge) {
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX;value={type=DVALUE_PARENT};index='height'});
		custom_update_code = "if self.height > self.max_height then\nself:set_height( self.max_height )\nend";
	};
	ENVIRONMENT(max-height) {
		none = math.huge;
	};
}
