
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.sml.SMLNodeDecoder'
 -- @endif

 -- @print Including sheets.sml.SMLNodeDecoder

class "SMLNodeDecoder" {
	name = "node";
	isBodyAllowed = false;
	isBodyNecessary = false;
}

function SMLNodeDecoder:SMLNodeDecoder( name )
	self.name = name
end

function SMLNodeDecoder:init( node )

end

function SMLNodeDecoder:decodeBody( body )

end
