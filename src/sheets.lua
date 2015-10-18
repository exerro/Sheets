
 -- @load sheets.noindent
 -- @noindent

 -- @defineifndef SHEETS_TYPE_CHECK true
 -- @defineifndef SHEETS_LOWRES true
 -- @defineifndef SHEETS_ANIMATION_FRAMERATE .05
 -- @defineifndef SHEETS_WRAP false
 -- @defineifndef SHEETS_EXTERNAL false

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
 -- @print Including sheets (animation-fps: $SHEETS_ANIMATION_FRAMERATE, low resolution: $SHEETS_LOWRES, type-check: $SHEETS_TYPE_CHECK, wrap: $SHEETS_WRAP, external: $SHEETS_EXTERNAL)

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

 -- @define SML_TOKEN_STRING 0
 -- @define SML_TOKEN_EQUAL 1
 -- @define SML_TOKEN_OPEN 2
 -- @define SML_TOKEN_CLOSE 3
 -- @define SML_TOKEN_SLASH 4
 -- @define SML_TOKEN_NUMBER 5
 -- @define SML_TOKEN_BOOL 6
 -- @define SML_TOKEN_IDENTIFIER 7
 -- @define SML_TOKEN_UNKNOWN 8
 -- @define SML_TOKEN_EOF 9

 -- @include graphics

 -- @require sheets.timer

 -- @require sheets.interfaces.IAnimation
 -- @require sheets.interfaces.IChildContainer
 -- @require sheets.interfaces.IPosition
 -- @require sheets.interfaces.IEvent
 -- @require sheets.interfaces.IParentContainer
 -- @require sheets.interfaces.IPositionAnimator

 -- @require sheets.sml.SMLNode
 -- @require sheets.sml.SMLParser

 -- @require sheets.animation.KeyFrame
 -- @require sheets.animation.Pause
 -- @require sheets.animation.Animation

 -- @require sheets.events.KeyboardEvent
 -- @require sheets.events.MiscEvent
 -- @require sheets.events.MouseEvent
 -- @require sheets.events.TextEvent
 -- @require sheets.events.TimerEvent

 -- @require sheets.Theme

 -- @require sheets.Application
 -- @require sheets.View
 -- @require sheets.Sheet

 -- @if SHEETS_WRAP
	end
	f()
 -- @endif
 -- @if SHEETS_EXTERNAL
 	return sheets
 -- @endif
