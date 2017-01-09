
 -- @once
 -- @print Including sheets.graphics.shader

local shader_darken_lookup = {
	[WHITE] = LIGHTGREY;
	[ORANGE] = RED;
	[MAGENTA] = PURPLE;
	[LIGHTBLUE] = CYAN;
	[YELLOW] = ORANGE;
	[LIME] = GREEN;
	[PINK] = MAGENTA;
	[GREY] = BLACK;
	[LIGHTGREY] = GREY;
	[CYAN] = BLUE;
	[PURPLE] = GREY;
	[BLUE] = GREY;
	[BROWN] = BLACK;
	[GREEN] = GREY;
	[RED] = BROWN;
	[BLACK] = BLACK;
}
local shader_lighten_lookup = {
	[WHITE] = WHITE;
	[ORANGE] = YELLOW;
	[MAGENTA] = PINK;
	[LIGHTBLUE] = WHITE;
	[YELLOW] = WHITE;
	[LIME] = WHITE;
	[PINK] = WHITE;
	[GREY] = LIGHTGREY;
	[LIGHTGREY] = WHITE;
	[CYAN] = LIGHTBLUE;
	[PURPLE] = MAGENTA;
	[BLUE] = CYAN;
	[BROWN] = RED;
	[GREEN] = LIME;
	[RED] = ORANGE;
	[BLACK] = GREY;
}
local shader_greyscale_lookup = {
	[WHITE] = WHITE;
	[ORANGE] = LIGHTGREY;
	[MAGENTA] = LIGHTGREY;
	[LIGHTBLUE] = LIGHTGREY;
	[YELLOW] = WHITE;
	[LIME] = LIGHTGREY;
	[PINK] = WHITE;
	[GREY] = GREY;
	[LIGHTGREY] = LIGHTGREY;
	[CYAN] = GREY;
	[PURPLE] = GREY;
	[BLUE] = GREY;
	[BROWN] = BLACK;
	[GREEN] = GREY;
	[RED] = GREY;
	[BLACK] = BLACK;
}
local shader_inverse_lookup = {
	[WHITE] = BLACK;
	[ORANGE] = BLUE;
	[MAGENTA] = GREEN;
	[LIGHTBLUE] = BROWN;
	[YELLOW] = BLUE;
	[LIME] = PURPLE;
	[PINK] = GREEN;
	[GREY] = LIGHTGREY;
	[LIGHTGREY] = GREY;
	[CYAN] = RED;
	[PURPLE] = GREEN;
	[BLUE] = YELLOW;
	[BROWN] = LIGHTBLUE;
	[GREEN] = PURPLE;
	[RED] = CYAN;
	[BLACK] = WHITE;
}

shader = {}

function shader.darken( col, ... )
	return shader_darken_lookup[col] or col, ...
end

function shader.lighten( col, ... )
	return shader_lighten_lookup[col] or col, ...
end

function shader.greyscale( col, ... )
	return shader_greyscale_lookup[col] or col, ...
end

function shader.inverse( col, ... )
	return shader_inverse_lookup[col] or col, ...
end