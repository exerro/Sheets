
 -- @once

 -- @ifndef __INCLUDE_sheets
	 -- @error 'sheets' must be included before including 'sheets.graphics.Font'
 -- @endif

 -- @print Including sheets.graphics.Font

 -- @error GRAPHICS_NO_TEXT flag is not yet supported

local defaultHeader = {
	mode = "bitmap";
	height = 8;
}

local defaultCharacters = {
	['A'] = { width = 5;
		{ 0, 0, 1, 0, 0 };
		{ 0, 1, 0, 1, 0 };
		{ 0, 1, 0, 1, 0 };
		{ 1, 0, 0, 0, 1 };
		{ 1, 1, 1, 1, 1 };
		{ 1, 0, 0, 0, 1 };
		{ 1, 0, 0, 0, 1 };
		{ 1, 0, 0, 0, 1 } };
}

local function decodeFileHeader( h )

end

local function decodeFileCharacters( h )

end

class "Font" {
	file = "";
	size = 1;
	mode = "bitmap";
	characters = {};
}

function Font:Font( file, size )
	if not size and type( file ) == "number" then
		file, size = nil, file
	end
	size = size or 8
	if file and type( file ) ~= "string" then return error( "expected string file, got " .. class.type( file ) ) end
	if type( size ) ~= "number" then return error( "expected number size, got " .. class.type( size ) ) end

	local header, characters

	if file then
		local h = fs.open( file, "rb" )
		if h then
			header = decodeFileHeader( h )
			characters = decodeFileCharacters( h )
		else
			return error( "File '" .. file .. "' cannot be opened", 2 )
		end
	else
		header = defaultHeader
		characters = defaultCharacters
	end
end
