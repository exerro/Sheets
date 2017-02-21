
 -- @print including(interfaces.ISize)

local WIDTH_PERCENTAGE_ENABLE = [[
parser.flags.enable_percentages = true
percentage_ast = { type = DVALUE_DOTINDEX, value = { type = DVALUE_PARENT }, index = "width" }
environment.expand={type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="x"}}]]

local HEIGHT_PERCENTAGE_ENABLE = [[
parser.flags.enable_percentages = true
percentage_ast = { type = DVALUE_DOTINDEX, value = { type = DVALUE_PARENT }, index = "height" }
environment.expand={type=DVALUE_BINEXPR,operator="-",lvalue={type=DVALUE_PERCENTAGE,value={type=DVALUE_INTEGER,value="100"}},rvalue={type=DVALUE_IDENTIFIER,value="y"}}]]

@interface ISize {
	width = 0;
	height = 0;
}

function ISize:ISize()
	self.values:add( "width", 0, { update_surface_size = true, custom_environment_code = WIDTH_PERCENTAGE_ENABLE } )
	self.values:add( "height", 0, { update_surface_size = true, custom_environment_code = HEIGHT_PERCENTAGE_ENABLE } )
end
