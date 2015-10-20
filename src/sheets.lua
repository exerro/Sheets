
 -- @load sheets.preprocessor.noindent
 -- @noindent

 -- @defineifndef SHEETS_LOWRES true
 -- @defineifndef SHEETS_ANIMATION_FRAMERATE .05
 -- @defineifndef SHEETS_WRAP false
 -- @defineifndef SHEETS_EXTERNAL false
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_TIME .3
 -- @defineifndef SHEETS_DEFAULT_TRANSITION_EASING SHEETS_EASING_TRANSITION

 -- @if SHEETS_LOWRES
	 -- @define GRAPHICS_NO_TEXT false
 -- @else
	 -- @define GRAPHICS_NO_TEXT true
 -- @endif

 -- @if SHEETS_WRAP
	local sheets = setmetatable( {}, { __index = _ENV } )
	local function f()
		local _ENV = sheets
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
 -- @define SHEETS_EVENT_KEY_DOWN 6
 -- @define SHEETS_EVENT_KEY_UP 7
 -- @define SHEETS_EVENT_TEXT 8
 -- @define SHEETS_EVENT_VOICE 9
 -- @define SHEETS_EVENT_TIMER 10
 -- @define SHEETS_EVENT_PASTE 11
 -- @define SHEETS_EVENT_MOUSE_PING 12

 -- @define ALIGNMENT_LEFT 0
 -- @define ALIGNMENT_CENTRE 1
 -- @define ALIGNMENT_CENTER ALIGNMENT_CENTRE
 -- @define ALIGNMENT_RIGHT 2
 -- @define ALIGNMENT_TOP 3
 -- @define ALIGNMENT_BOTTOM 4

 -- @define SHEETS_EASING_EXIT 0
 -- @define SHEETS_EASING_ENTRANCE 1
 -- @define SHEETS_EASING_TRANSITION 2

event = {
	mouse_down = SHEETS_EVENT_MOUSE_DOWN;
	mouse_up = SHEETS_EVENT_MOUSE_UP;
	mouse_click = SHEETS_EVENT_MOUSE_CLICK;
	mouse_hold = SHEETS_EVENT_MOUSE_HOLD;
	mouse_drag = SHEETS_EVENT_MOUSE_DRAG;
	mouse_scroll = SHEETS_EVENT_MOUSE_SCROLL;
	key_down = SHEETS_EVENT_KEY_DOWN;
	key_up = SHEETS_EVENT_KEY_UP;
	text = SHEETS_EVENT_TEXT;
	voice = SHEETS_EVENT_VOICE;
	timer = SHEETS_EVENT_TIMER;
	paste = SHEETS_EVENT_PASTE;
	mouse_ping = SHEETS_EVENT_MOUSE_PING;
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

 -- @require sheets.interfaces.IAnimation
 -- @require sheets.interfaces.IChildContainer
 -- @require sheets.interfaces.IChildDecoder
 -- @require sheets.interfaces.ICommon
 -- @require sheets.interfaces.IEvent
 -- @require sheets.interfaces.IHasID
 -- @require sheets.interfaces.IHasParent
 -- @require sheets.interfaces.IHasText
 -- @require sheets.interfaces.IHasTheme
 -- @require sheets.interfaces.IPosition
 -- @require sheets.interfaces.IPositionAnimator
 -- @require sheets.interfaces.attributes.IAnimatedPositionAttributes
 -- @require sheets.interfaces.attributes.ICommonAttributes
 -- @require sheets.interfaces.attributes.IPositionAttributes
 -- @require sheets.interfaces.attributes.ITextAttributes
 -- @require sheets.interfaces.attributes.IThemeAttribute

 -- @require sheets.sml.SMLNode
 -- @require sheets.sml.SMLParser
 -- @require sheets.sml.SMLNodeDecoder
 -- @require sheets.sml.SMLDocument

 -- @require sheets.animation.KeyFrame
 -- @require sheets.animation.Pause
 -- @require sheets.animation.Animation

 -- @require sheets.events.KeyboardEvent
 -- @require sheets.events.MiscEvent
 -- @require sheets.events.MouseEvent
 -- @require sheets.events.TextEvent
 -- @require sheets.events.TimerEvent

 -- @require sheets.Theme

default_theme = Theme()

 -- @require sheets.Application
 -- @require sheets.Sheet

 -- @require sheets.View

SMLDocument:setVariable( "transparent", TRANSPARENT )
SMLDocument:setVariable( "white", WHITE )
SMLDocument:setVariable( "orange", ORANGE )
SMLDocument:setVariable( "magenta", MAGENTA )
SMLDocument:setVariable( "lightBlue", LIGHTBLUE )
SMLDocument:setVariable( "yellow", YELLOW )
SMLDocument:setVariable( "lime", LIME )
SMLDocument:setVariable( "pink", PINK )
SMLDocument:setVariable( "grey", GREY )
SMLDocument:setVariable( "lightGrey", LIGHTGREY )
SMLDocument:setVariable( "cyan", CYAN )
SMLDocument:setVariable( "purple", PURPLE )
SMLDocument:setVariable( "blue", BLUE )
SMLDocument:setVariable( "brown", BROWN )
SMLDocument:setVariable( "green", GREEN )
SMLDocument:setVariable( "red", RED )
SMLDocument:setVariable( "black", BLACK )

 -- @if SHEETS_WRAP
	end
	f()
 -- @endif
 -- @if SHEETS_EXTERNAL
 	return sheets
 -- @endif
