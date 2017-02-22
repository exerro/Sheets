
 -- @include component

COMPONENT(size) {
	PROPERTY(width, 0) {
		update_surface_size = true;
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX,value={type=DVALUE_PARENT},index="width"});
	};
	ENVIRONMENT(width) {
		expand = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="x"}}
	};
	PROPERTY(height, 0) {
		update_surface_size = true;
		ENABLE_PERCENTAGES({type=DVALUE_DOTINDEX,value={type=DVALUE_PARENT},index="height"});
	};
	ENVIRONMENT(height) {
		expand = {type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="y"}}
	}
}
