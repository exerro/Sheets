
local sin, cos = math.sin, math.cos
local halfpi = math.pi / 2

enum "Easing" {
	linear = function( u, d, t )
		return u + d * t
	end;

	smooth = function( u, d, t )
		return u + d * ( 3 * t * t - 2 * t * t * t )
	end;

	exit = function( u, d, t )
		return -d * cos(t * halfpi) + d + u
	end;

	entrance = function( u, d, t )
		return u + d * sin(t * halfpi)
	end;

	-- TODO: probably should add in all the default ones but why are they required?
}
