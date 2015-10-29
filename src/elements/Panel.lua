
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.Panel'
 -- @endif

 -- @print Including sheets.elements.Panel

class "Panel" extends "Sheet" {}

function Panel:onPreDraw()
	self.canvas:clear( self.style:getField "colour" )
end

Style.addToTemplate( Panel, {
	["colour"] = LIGHTGREY;
} )
