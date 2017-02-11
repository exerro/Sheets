
 -- @defineifndef SHEETS_LOWRES true
 -- @defineifndef SHEETS_MINIFY
 -- @defineifndef SHEETS_SML false
 -- @defineifndef SHEETS_WRAP false
 -- @defineifndef SHEETS_EXTERNAL false

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
 -- @require lib.clipboard
 -- @require lib.parameters
 -- @require lib.query_utils
 -- @require lib.timer

 -- @include surface2

 -- @require enum.Easing

 -- @require exceptions.Exception
 -- @require exceptions.IncorrectParameterException
 -- @require exceptions.IncorrectConstructorException
 -- @require exceptions.ResourceLoadException
 -- @require exceptions.ThreadRuntimeException

 -- @require interfaces.ICollatedChildren
 -- @require interfaces.IQueryable
 -- @require interfaces.IChildContainer
 -- @require interfaces.ITagged
 -- @require interfaces.ISize

 -- @require events.Event
 -- @require events.KeyboardEvent
 -- @require events.MiscEvent
 -- @require events.MouseEvent
 -- @require events.TextEvent

 -- @require parsing.Stream
 -- @require parsing.QueryParser
 -- @require parsing.DynamicValueParser

 -- @require core.Animation
 -- @require core.Application
 -- @require core.Codegen
 -- @require core.QueryTracker
 -- @require core.Screen
 -- @require core.Sheet
 -- @require core.Thread
 -- @require core.Transition
 -- @require core.ValueHandler

 -- @if SHEETS_BUTTON
	 -- @require interfaces.IHasText
	 -- @require elements.Button
 -- @endif
 -- @if SHEETS_CHECKBOX
	 -- @/require elements.Checkbox
 -- @endif
 -- @if SHEETS_CONTAINER
	 -- @require elements.Container
 -- @endif
 -- @if SHEETS_DRAGGABLE
 	 -- @/require interfaces.IHasText
	 -- @/require elements.Draggable
 -- @endif
 -- @if SHEETS_IMAGE
	 -- @/require elements.Image
 -- @endif
 -- @if SHEETS_KEYHANDLER
 	 -- @require elements.KeyHandler
 -- @endif
 -- @if SHEETS_PANEL
	 -- @require elements.Panel
 -- @endif
 -- @if SHEETS_SCROLLCONTAINER
	 -- @/require elements.ScrollContainer
 -- @endif
 -- @if SHEETS_TEXT
 	 -- @/require interfaces.IHasText
	 -- @/require elements.Text
 -- @endif
 -- @if SHEETS_TEXTINPUT
	 -- @/require elements.TextInput
 -- @endif

 -- @if SHEETS_WRAP
	end
	f()
	local sheets = {}
	for k, v in pairs( env ) do
		sheets[k] = v
	end
	env.class.set_environment( sheets )
 -- @endif
 -- @if SHEETS_EXTERNAL
 	return sheets
 -- @endif
