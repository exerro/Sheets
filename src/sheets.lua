
 -- @defineifndef SHEETS_TYPE_CHECK false
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
 -- @define SHEETS_EVENT_RESOLUTION_CHANGE 10
 -- @define SHEETS_EVENT_TIMER 11

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

 -- @define SML_EMPTY_BODY nil

 -- @define SML_ERROR_STRING 0
 -- @define SML_ERROR_NUMBER 1

 -- @include graphics

 -- @require sheets.sml.SMLNode
 -- @require sheets.sml.SMLParser

 -- @require sheets.KeyFrame
 -- @require sheets.Animation

 -- @include sheets.timer
 -- @require sheets.Application
 -- @require sheets.Theme
 -- @require sheets.Sheet

 -- @if SHEET_WRAP
	end
	f()
 -- @endif
 -- @if SHEET_EXTERNAL
 	return sheets
 -- @endif
