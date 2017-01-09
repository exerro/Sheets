
 -- @defineifndef SHEETS_LOWRES true
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_TIME .3
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_EASING "transition"
 -- @defineifndef SHEETS_MINIFY
 -- @defineifndef SHEETS_PARSING
 -- @defineifndef SHEETS_DYNAMIC
 -- @defineifndef SHEETS_DYNAMIC_PARSING
 -- @defineifndef SHEETS_SML false
 -- @defineifndef SHEETS_WRAP false
 -- @defineifndef SHEETS_EXTERNAL false

 -- @if SHEETS_DYNAMIC_PARSING
	-- @error "dynamic value parsing is not yet implemented"
 -- @endif

 -- @if SHEETS_SML
	-- @error "SML is not yet implemented"
 -- @endif

 -- @once
 -- @print Including sheets (minify: $SHEETS_MINIFY, low resolution: $SHEETS_LOWRES, dynamic-values: $SHEETS_DYNAMIC (expressions: $SHEETS_DYNAMIC_PARSING), sml: $SHEETS_SML)

 -- @define SHEETS_EXCEPTION_ERROR "SHEETS_EXCEPTION\n_put code in a try block to catch the exception."

 -- @include constants

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
	light_blue = LIGHTBLUE;
	yellow = YELLOW;
	lime = LIME;
	pink = PINK;
	grey = GREY;
	light_grey = LIGHTGREY;
	cyan = CYAN;
	purple = PURPLE;
	blue = BLUE;
	brown = BROWN;
	green = GREEN;
	red = RED;
	black = BLACK;
}

token = {
	eof = TOKEN_EOF;
	string = TOKEN_STRING;
	float = TOKEN_FLOAT;
	int = TOKEN_INT;
	ident = TOKEN_IDENT;
	newline = TOKEN_NEWLINE;
	symbol = TOKEN_SYMBOL;
	operator = TOKEN_OPERATOR;
}

 -- @require lib.class
 -- @require lib.timer
 -- @require lib.clipboard
 -- @require lib.parameters

 -- @ifn SHEETS_LOWRES
	 -- @require graphics.Font
	GRAPHICS_DEFAULT_FONT = Font()
 -- @endif

 -- @include graphics.shader
 -- @require graphics.Canvas
 -- @require graphics.DrawingCanvas
 -- @require graphics.ScreenCanvas
 -- @require graphics.image

 -- @require exceptions.Exception
 -- @require exceptions.IncorrectParameterException
 -- @require exceptions.IncorrectConstructorException
 -- @require exceptions.ResourceLoadException
 -- @require exceptions.ThreadRuntimeException

 -- @require interfaces.IAnimation
 -- @require interfaces.IAttributeAnimator
 -- @require interfaces.IChildContainer
 -- @require interfaces.ISize

 -- @require events.Event
 -- @require events.KeyboardEvent
 -- @require events.MiscEvent
 -- @require events.MouseEvent
 -- @require events.TextEvent

 -- @require core.Animation
 -- @require core.Application
 -- @require core.Screen
 -- @require core.Sheet
 -- @require core.Style
 -- @require core.Thread

 -- @if SHEETS_PARSING
	 -- @require exceptions.ParserException
	 -- @require parsing.TokenPosition
	 -- @require parsing.Token
	 -- @require parsing.Parser
 -- @endif

 -- @if SHEETS_BUTTON
	 -- @require interfaces.IHasText
	 -- @require elements.Button
 -- @endif
 -- @if SHEETS_CHECKBOX
	 -- @require elements.Checkbox
 -- @endif
 -- @if SHEETS_CONTAINER
	 -- @require elements.Container
 -- @endif
 -- @if SHEETS_DRAGGABLE
 	 -- @require interfaces.IHasText
	 -- @require elements.Draggable
 -- @endif
 -- @if SHEETS_IMAGE
	 -- @require elements.Image
 -- @endif
 -- @if SHEETS_KEYHANDLER
 	 -- @require elements.KeyHandler
 -- @endif
 -- @if SHEETS_PANEL
	 -- @require elements.Panel
 -- @endif
 -- @if SHEETS_SCROLLCONTAINER
	 -- @require elements.ScrollContainer
 -- @endif
 -- @if SHEETS_TEXT
 	 -- @require interfaces.IHasText
	 -- @require elements.Text
 -- @endif
 -- @if SHEETS_TEXTINPUT
	 -- @require elements.TextInput
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
