
 -- @defineifndef LOWRES true
 -- @defineifndef SML false
 -- @defineifndef THREADING true
 -- @defineifndef CORE_ELEMENTS true

 -- @define including(x) Including file sheets.x

 -- @if SML
	-- @error "SML is not yet implemented"
 -- @endif

 -- @print Including sheets (low resolution: $LOWRES, sml: $SML)

 -- @define EXCEPTION_ERROR "EXCEPTION\nPut code in a try block to catch the exception."

 -- @include constants

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

 -- @include lib.class
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

 -- @unset EVENT_MOUSE_DOWN
 -- @unset EVENT_MOUSE_UP
 -- @unset EVENT_MOUSE_CLICK
 -- @unset EVENT_MOUSE_HOLD
 -- @unset EVENT_MOUSE_DRAG
 -- @unset EVENT_MOUSE_SCROLL
 -- @unset EVENT_MOUSE_PING
 -- @unset EVENT_KEY_DOWN
 -- @unset EVENT_KEY_UP
 -- @unset EVENT_TEXT
 -- @unset EVENT_VOICE
 -- @unset EVENT_PASTE
 -- @unset TOKEN_EOF
 -- @unset TOKEN_STRING
 -- @unset TOKEN_FLOAT
 -- @unset TOKEN_BOOLEAN
 -- @unset TOKEN_INTEGER
 -- @unset TOKEN_IDENTIFIER
 -- @unset TOKEN_KEYWORD
 -- @unset TOKEN_NEWLINE
 -- @unset TOKEN_WHITESPACE
 -- @unset TOKEN_SYMBOL
 -- @unset QUERY_ANY
 -- @unset QUERY_ID
 -- @unset QUERY_TAG
 -- @unset QUERY_CLASS
 -- @unset QUERY_ATTRIBUTES
 -- @unset QUERY_NEGATE
 -- @unset QUERY_OPERATOR
 -- @unset DVALUE_SELF
 -- @unset DVALUE_APPLICATION
 -- @unset DVALUE_PARENT
 -- @unset DVALUE_IDENTIFIER
 -- @unset DVALUE_INTEGER
 -- @unset DVALUE_FLOAT
 -- @unset DVALUE_BOOLEAN
 -- @unset DVALUE_STRING
 -- @unset DVALUE_PERCENTAGE
 -- @unset DVALUE_QUERY
 -- @unset DVALUE_DQUERY
 -- @unset DVALUE_DOTINDEX
 -- @unset DVALUE_CALL
 -- @unset DVALUE_INDEX
 -- @unset DVALUE_UNEXPR
 -- @unset DVALUE_BINEXPR
 -- @unset DVALUE_FLOOR
 -- @unset DVALUE_TOSTRING
 -- @unset DVALUE_TAG_CHECK
 -- @unset CORE_ELEMENT
 -- @unset ELEMENT_BUTTON
 -- @unset ELEMENT_CHECKBOX
 -- @unset ELEMENT_CLIPPEDCONTAINER
 -- @unset ELEMENT_COLOURSELECTOR
 -- @unset ELEMENT_DRAGGABLE
 -- @unset ELEMENT_IMAGE
 -- @unset ELEMENT_KEYHANDLER
 -- @unset ELEMENT_LABEL
 -- @unset ELEMENT_MENU
 -- @unset ELEMENT_PANEL
 -- @unset ELEMENT_RADIOBUTTON
 -- @unset ELEMENT_SCROLLCONTAINER
 -- @unset ELEMENT_TABS
 -- @unset ELEMENT_TERMINAL
 -- @unset ELEMENT_TEXT
 -- @unset ELEMENT_TEXTINPUT
 -- @unset ELEMENT_TOGGLE
 -- @unset ELEMENT_WINDOW
 -- @unset LOWRES
 -- @unset SML
 -- @unset THREADING
 -- @unset EXCEPTION_ERROR
 -- @unset including
 -- @unset PATH
