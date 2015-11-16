
 -- @defineifndef SHEETS_LOWRES true
 -- @defineifndef SHEETS_ANIMATION_FRAMERATE .05
 -- @defineifndef SHEETS_WRAP false
 -- @defineifndef SHEETS_EXTERNAL false
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_TIME .3
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_EASING "transition"
 -- @defineifndef SHEETS_MINIFY
 -- @defineifndef SHEETS_PARSING
 -- @defineifndef SHEETS_DYNAMIC
 -- @defineifndef SHEETS_DYNAMIC_PARSING
 -- @defineifndef SHEETS_SML

 -- @if SHEETS_DYNAMIC_PARSING
 	-- @define SHEETS_PARSING
 	-- @define SHEETS_DYNAMIC
 -- @elif SHEETS_SML
 	-- @define SHEETS_PARSING
 -- @endif

 -- @if SHEETS_CORE_ELEMENTS
	 -- @define SHEETS_BUTTON
	 -- @define SHEETS_CHECKBOX
	 -- @define SHEETS_COLOURSELECTOR
	 -- @define SHEETS_CONTAINER
	 -- @define SHEETS_DRAGGABLE
	 -- @define SHEETS_IMAGE
	 -- @define SHEETS_KEYHANDLER
	 -- @define SHEETS_LABEL
	 -- @define SHEETS_MENU
	 -- @define SHEETS_PANEL
	 -- @define SHEETS_RADIOBUTTON
	 -- @define SHEETS_SCROLLCONTAINER
	 -- @define SHEETS_TABS
	 -- @define SHEETS_TERMINAL
	 -- @define SHEETS_TEXT
	 -- @define SHEETS_TEXTINPUT
	 -- @define SHEETS_TOGGLE
	 -- @define SHEETS_WINDOW
 -- @endif

 -- @if SHEETS_LOWRES
	 -- @define GRAPHICS_NO_TEXT false
 -- @else
	 -- @define GRAPHICS_NO_TEXT true
 -- @endif

 -- @once
 -- @define __INCLUDE_sheets
 -- @print Including sheets (minify: $SHEETS_MINIFY, transition-time: $SHEETS_DEFAULT_TRANSITION_TIME, transition-easing: $SHEETS_DEFAULT_TRANSITION_EASING animation-fps: $SHEETS_ANIMATION_FRAMERATE, low resolution: $SHEETS_LOWRES, wrap: $SHEETS_WRAP, external: $SHEETS_EXTERNAL)

 -- @define SHEETS_EXCEPTION_ERROR "SHEETS_EXCEPTION\nPut code in a try block to catch the exception."

 -- @define SHEETS_EVENT_MOUSE_DOWN 0
 -- @define SHEETS_EVENT_MOUSE_UP 1
 -- @define SHEETS_EVENT_MOUSE_CLICK 2
 -- @define SHEETS_EVENT_MOUSE_HOLD 3
 -- @define SHEETS_EVENT_MOUSE_DRAG 4
 -- @define SHEETS_EVENT_MOUSE_SCROLL 5
 -- @define SHEETS_EVENT_MOUSE_PING 6
 -- @define SHEETS_EVENT_KEY_DOWN 7
 -- @define SHEETS_EVENT_KEY_UP 8
 -- @define SHEETS_EVENT_TEXT 9
 -- @define SHEETS_EVENT_VOICE 10
 -- @define SHEETS_EVENT_PASTE 11

 -- @define ALIGNMENT_LEFT 0
 -- @define ALIGNMENT_CENTRE 1
 -- @define ALIGNMENT_CENTER ALIGNMENT_CENTRE
 -- @define ALIGNMENT_RIGHT 2
 -- @define ALIGNMENT_TOP 3
 -- @define ALIGNMENT_BOTTOM 4
 
 -- @define GRAPHICS_AREA_BOX 0
 -- @define GRAPHICS_AREA_CIRCLE 1
 -- @define GRAPHICS_AREA_LINE 2
 -- @define GRAPHICS_AREA_VLINE 3
 -- @define GRAPHICS_AREA_HLINE 4
 -- @define GRAPHICS_AREA_FILL 5
 -- @define GRAPHICS_AREA_POINT 6
 -- @define GRAPHICS_AREA_CCIRCLE 7

 -- @define TRANSPARENT 0
 -- @define WHITE 1
 -- @define ORANGE 2
 -- @define MAGENTA 4
 -- @define LIGHTBLUE 8
 -- @define YELLOW 16
 -- @define LIME 32
 -- @define PINK 64
 -- @define GREY 128
 -- @define LIGHTGREY 256
 -- @define CYAN 512
 -- @define PURPLE 1024
 -- @define BLUE 2048
 -- @define BROWN 4096
 -- @define GREEN 8192
 -- @define RED 16384
 -- @define BLACK 32768

 -- @if SHEETS_PARSING
	 -- @define TOKEN_EOF "eof"
	 -- @define TOKEN_STRING "string"
	 -- @define TOKEN_FLOAT "float"
	 -- @define TOKEN_INT "int"
	 -- @define TOKEN_IDENT "identifier"
	 -- @define TOKEN_NEWLINE "newline"
	 -- @define TOKEN_SYMBOL "symbol"
	 -- @define TOKEN_OPERATOR "operator"
 -- @endif

 -- @if SHEETS_DYNAMIC_PARSING
 	 -- @define OPERATOR_UNARY_MINUS 0
 	 -- @define OPERATOR_UNARY_LEN 1
 	 -- @define OPERATOR_UNARY_NOT 2
 	 -- @define OPERATOR_UNARY_CALL 3
 	 -- @define OPERATOR_UNARY_INDEX 4
 	 -- @define OPERATOR_BINARY_ADD 5
 	 -- @define OPERATOR_BINARY_SUB 6
 	 -- @define OPERATOR_BINARY_MUL 7
 	 -- @define OPERATOR_BINARY_DIV 8
 	 -- @define OPERATOR_BINARY_MOD 9
 	 -- @define OPERATOR_BINARY_POW 10
 -- @endif

 -- @if SHEETS_LOWRES
	 -- @define BLANK_PIXEL { WHITE, WHITE, " " }
 -- @else
 	 -- @define BLANK_PIXEL WHITE
 -- @endif

 -- @if SHEETS_LOWRES
	 -- @define CIRCLE_CORRECTION 1.5
 -- @else
	 -- @define CIRCLE_CORRECTION 1
 -- @endif

 -- @if SHEETS_WRAP
	local env = setmetatable( {}, { __index = _ENV } )
	local function f()
		local _ENV = env
		if setfenv then
			setfenv( 1, env )
		end
 -- @endif

event = {
	mouse_down = SHEETS_EVENT_MOUSE_DOWN;
	mouse_up = SHEETS_EVENT_MOUSE_UP;
	mouse_click = SHEETS_EVENT_MOUSE_CLICK;
	mouse_hold = SHEETS_EVENT_MOUSE_HOLD;
	mouse_drag = SHEETS_EVENT_MOUSE_DRAG;
	mouse_scroll = SHEETS_EVENT_MOUSE_SCROLL;
	mouse_ping = SHEETS_EVENT_MOUSE_PING;
	key_down = SHEETS_EVENT_KEY_DOWN;
	key_up = SHEETS_EVENT_KEY_UP;
	text = SHEETS_EVENT_TEXT;
	voice = SHEETS_EVENT_VOICE;
	paste = SHEETS_EVENT_PASTE;
}

alignment = {
	left = ALIGNMENT_LEFT;
	centre = ALIGNMENT_CENTRE;
	center = ALIGNMENT_CENTRE;
	right = ALIGNMENT_RIGHT;
	top = ALIGNMENT_TOP;
	bottom = ALIGNMENT_BOTTOM;
}

area = {
	box = GRAPHICS_AREA_BOX;
	circle = GRAPHICS_AREA_CIRCLE;
	line = GRAPHICS_AREA_LINE;
	vline = GRAPHICS_AREA_VLINE;
	hline = GRAPHICS_AREA_HLINE;
	fill = GRAPHICS_AREA_FILL;
	point = GRAPHICS_AREA_POINT;
	ccircle = GRAPHICS_AREA_CCIRCLE;
}

colour = {
	transparent = TRANSPARENT;
	white = WHITE;
	orange = ORANGE;
	magenta = MAGENTA;
	lightBlue = LIGHTBLUE;
	yellow = YELLOW;
	lime = LIME;
	pink = PINK;
	grey = GREY;
	lightGrey = LIGHTGREY;
	cyan = CYAN;
	purple = PURPLE;
	blue = BLUE;
	brown = BROWN;
	green = GREEN;
	red = RED;
	black = BLACK;
}

 -- @require sheets.lib.class
 -- @require sheets.lib.timer
 -- @require sheets.lib.clipboard
 -- @require sheets.lib.parameters

 -- @ifn SHEETS_LOWRES
	 -- @define GRAPHICS_DEFAULT_FONT _graphics_default_font
	 -- @require graphics.Font
	GRAPHICS_DEFAULT_FONT = Font()
 -- @endif

 -- @include sheets.graphics.shader
 -- @require sheets.graphics.Canvas
 -- @require sheets.graphics.DrawingCanvas
 -- @require sheets.graphics.ScreenCanvas
 -- @require sheets.graphics.image

 -- @require sheets.exceptions.Exception
 -- @require sheets.exceptions.IncorrectParameterException
 -- @require sheets.exceptions.IncorrectConstructorException
 -- @require sheets.exceptions.ResourceLoadException
 -- @require sheets.exceptions.ThreadRuntimeException

 -- @require sheets.interfaces.IAnimation
 -- @require sheets.interfaces.IAttributeAnimator
 -- @require sheets.interfaces.IChildContainer
 -- @require sheets.interfaces.ISize

 -- @require sheets.events.Event
 -- @require sheets.events.KeyboardEvent
 -- @require sheets.events.MiscEvent
 -- @require sheets.events.MouseEvent
 -- @require sheets.events.TextEvent

 -- @require sheets.core.Animation
 -- @require sheets.core.Application
 -- @require sheets.core.Screen
 -- @require sheets.core.Sheet
 -- @require sheets.core.Style
 -- @require sheets.core.Thread

 -- @if SHEETS_PARSING
	 -- @require sheets.exceptions.ParserException
	 -- @require sheets.parsing.TokenPosition
	 -- @require sheets.parsing.Token
	 -- @require sheets.parsing.Parser
 -- @endif

 -- @if SHEETS_DYNAMIC
	 -- @require sheets.exceptions.DynamicValueException
	 -- @require sheets.dynamic.DynamicValueVendor
 -- @endif

 -- @if SHEETS_DYNAMIC_PARSING
 	 -- @require sheets.exceptions.ExpressionException
	 -- @require sheets.dynamic.ExpressionParser
	 -- @require sheets.dynamic.ExpressionEnvironment
	 -- @require sheets.dynamic.Expression
	 -- @require sheets.dynamic.BinaryExpression
	 -- @require sheets.dynamic.ConstantExpression
	 -- @require sheets.dynamic.IdentifierExpression
	 -- @require sheets.dynamic.UnaryLeftExpression
	 -- @require sheets.dynamic.UnaryRightExpression
 -- @endif

 -- @if SHEETS_BUTTON
	 -- @require sheets.interfaces.IHasText
	 -- @require sheets.elements.Button
 -- @endif
 -- @if SHEETS_CHECKBOX
	 -- @require sheets.elements.Checkbox
 -- @endif
 -- @if SHEETS_CONTAINER
	 -- @require sheets.elements.Container
 -- @endif
 -- @if SHEETS_DRAGGABLE
 	 -- @require sheets.interfaces.IHasText
	 -- @require sheets.elements.Draggable
 -- @endif
 -- @if SHEETS_IMAGE
	 -- @require sheets.elements.Image
 -- @endif
 -- @if SHEETS_KEYHANDLER
 	 -- @require sheets.elements.KeyHandler
 -- @endif
 -- @if SHEETS_PANEL
	 -- @require sheets.elements.Panel
 -- @endif
 -- @if SHEETS_SCROLLCONTAINER
	 -- @require sheets.elements.ScrollContainer
 -- @endif
 -- @if SHEETS_TEXT
 	 -- @require sheets.interfaces.IHasText
	 -- @require sheets.elements.Text
 -- @endif
 -- @if SHEETS_TEXTINPUT
	 -- @require sheets.elements.TextInput
 -- @endif

 -- @if SHEETS_WRAP
	end
	f()
	local sheets = {}
	for k, v in pairs( env ) do
		sheets[k] = v
	end
 -- @endif
 -- @if SHEETS_EXTERNAL
 	return sheets
 -- @endif
