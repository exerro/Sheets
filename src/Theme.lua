
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Theme'
 -- @endif

 -- @print Including sheets.Theme

class "Theme"
{
	primary = GREY;
	secondary = CYAN;
	accent = PINK;
}

function Theme:Theme( primary, secondary, accent )
	-- @if SHEETS_TYPE_CHECK

	-- @endif
	self.primary = primary
	self.secondary = secondary
	self.accent = accent
end

Theme.dark = Theme( GREY, WHITE, CYAN )
Theme.light = Theme( LIGHTGREY, WHITE, CYAN )
Theme.blue = Theme( BLUE, WHITE, MAGENTA )
