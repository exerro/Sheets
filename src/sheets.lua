
 -- @load sheets.preprocessor.noindent
 -- @noindent

 -- @defineifndef SHEETS_LOWRES true
 -- @defineifndef SHEETS_ANIMATION_FRAMERATE .05
 -- @defineifndef SHEETS_WRAP false
 -- @defineifndef SHEETS_EXTERNAL false
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_TIME .3
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_EASING "transition"

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

 -- @if SHEETS_WRAP
	local env = setmetatable( {}, { __index = _ENV } )
	local function f()
		local _ENV = env
		if setfenv then
			setfenv( 1, env )
		end
 -- @endif

 -- @once
 -- @define __INCLUDE_sheets
 -- @print Including sheets (transition-time: $SHEETS_DEFAULT_TRANSITION_TIME, transition-easing: $SHEETS_DEFAULT_TRANSITION_EASING animation-fps: $SHEETS_ANIMATION_FRAMERATE, low resolution: $SHEETS_LOWRES, wrap: $SHEETS_WRAP, external: $SHEETS_EXTERNAL)

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

 -- @include graphics

 -- @require sheets.timer
 -- @require sheets.clipboard

 -- @require sheets.exception
 -- @require sheets.functionParameters

 -- @require sheets.interfaces.core.IAnimation
 -- @require sheets.interfaces.core.IChildContainer
 -- @require sheets.interfaces.core.ICommon
 -- @require sheets.interfaces.core.IEvent
 -- @require sheets.interfaces.core.IHasParent
 -- @require sheets.interfaces.core.IPosition
 -- @require sheets.interfaces.core.IPositionAnimator

 -- @require sheets.interfaces.IHasText

 -- @require sheets.Animation
 -- @require sheets.Application
 -- @require sheets.Style

 -- @require sheets.events.KeyboardEvent
 -- @require sheets.events.MiscEvent
 -- @require sheets.events.MouseEvent
 -- @require sheets.events.TextEvent

 -- @require sheets.Sheet
 -- @require sheets.View

 -- @if SHEETS_BUTTON
	 -- @require sheets.elements.Button
 -- @endif
 -- @if SHEETS_CHECKBOX
	 -- @require sheets.elements.Checkbox
 -- @endif
 -- @if SHEETS_CONTAINER
	 -- @require sheets.elements.Container
 -- @endif
 -- @if SHEETS_DRAGGABLE
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
