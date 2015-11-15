
 -- @once

 -- @ifndef __INCLUDE_sheets
 	 -- @error 'sheets' must be included before including 'sheets.graphics'
 -- @endif

 -- @include colour

 -- @if GRAPHICS_NO_TEXT
 	 -- @define BLANK_PIXEL WHITE
 -- @else
	 -- @define BLANK_PIXEL { WHITE, WHITE, " " }
 -- @endif

 -- @if GRAPHICS_NO_TEXT
	 -- @define CIRCLE_CORRECTION 1
 -- @else
	 -- @define CIRCLE_CORRECTION 1.5
 -- @endif

 -- @if GRAPHICS_NO_TEXT
	 -- @define GRAPHICS_DEFAULT_FONT _graphics_default_font
	 -- @require graphics.Font
	GRAPHICS_DEFAULT_FONT = Font()
 -- @endif

 -- @include sheets.graphics.shader
 -- @require sheets.graphics.Canvas
 -- @require sheets.graphics.DrawingCanvas
 -- @require sheets.graphics.ScreenCanvas
 -- @require sheets.graphics.image
