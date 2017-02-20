
 -- @defineifndef LOWRES true
 -- @defineifndef MINIFY false
 -- @defineifndef SML false
 -- @defineifndef THREADING true

 -- @define including(x) Including file sheets.x

 -- @if SML
	-- @error "SML is not yet implemented"
 -- @endif

 -- @print Including sheets (minify: $MINIFY, low resolution: $LOWRES, sml: $SML)

 -- @define EXCEPTION_ERROR "EXCEPTION\nPut code in a try block to catch the exception."

 -- @include constants

event = {
	mouse_down = EVENT_MOUSE_DOWN;
	mouse_up = EVENT_MOUSE_UP;
	mouse_click = EVENT_MOUSE_CLICK;
	mouse_hold = EVENT_MOUSE_HOLD;
	mouse_drag = EVENT_MOUSE_DRAG;
	mouse_scroll = EVENT_MOUSE_SCROLL;
	mouse_ping = EVENT_MOUSE_PING;
	key_down = EVENT_KEY_DOWN;
	key_up = EVENT_KEY_UP;
	text = EVENT_TEXT;
	voice = EVENT_VOICE;
	paste = EVENT_PASTE;
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

 -- @include .sheets.lib.class
 -- @include lib.clipboard
 -- @include lib.parameters
 -- @include lib.surface2

 -- @include enum.Easing

 -- @include exceptions.Exception
 -- @include exceptions.IncorrectParameterException
 -- @include exceptions.IncorrectConstructorException
 -- @include exceptions.ResourceLoadException
 -- @include exceptions.ThreadRuntimeException

 -- @include interfaces.ICollatedChildren
 -- @include interfaces.IColoured
 -- @include interfaces.IQueryable
 -- @include interfaces.IChildContainer
 -- @include interfaces.ITagged
 -- @include interfaces.ISize
 -- @include interfaces.ITimer

 -- @include events.Event
 -- @include events.KeyboardEvent
 -- @include events.MiscEvent
 -- @include events.MouseEvent
 -- @include events.TextEvent

 -- @include dynamic.Codegen
 -- @include dynamic.DynamicValueParser
 -- @include dynamic.QueryTracker
 -- @include dynamic.Stream
 -- @include dynamic.Transition
 -- @include dynamic.Type
 -- @include dynamic.Typechecking
 -- @include dynamic.ValueHandler

 -- @include core.Application
 -- @include core.Screen
 -- @include core.Sheet

 -- @if THREADING
     -- @include core.Thread
 -- @endif

 -- @include elements.Container

 -- @if ELEMENT_BUTTON
	 -- @include interfaces.IHasText
	 -- @include elements.Button
 -- @endif
 -- @if ELEMENT_CHECKBOX
	 -- @/require elements.Checkbox
 -- @endif
 -- @if ELEMENT_CLIPPEDCONTAINER
	 -- @include elements.ClippedContainer
 -- @endif
 -- @if ELEMENT_DRAGGABLE
 	 -- @/require interfaces.IHasText
	 -- @/require elements.Draggable
 -- @endif
 -- @if ELEMENT_IMAGE
	 -- @/require elements.Image
 -- @endif
 -- @if ELEMENT_KEYHANDLER
 	 -- @include elements.KeyHandler
 -- @endif
 -- @if ELEMENT_PANEL
	 -- @include elements.Panel
 -- @endif
 -- @if ELEMENT_SCROLLCONTAINER
	 -- @/require elements.ScrollContainer
 -- @endif
 -- @if ELEMENT_TEXT
 	 -- @/require interfaces.IHasText
	 -- @/require elements.Text
 -- @endif
 -- @if ELEMENT_TEXTINPUT
	 -- @/require elements.TextInput
 -- @endif
