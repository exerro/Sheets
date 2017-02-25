
 -- @print including(enum.Easing)

local sin, cos = math.sin, math.cos
local halfpi = math.pi / 2

@enum Easing {
	linear = function( t )
		return t
	end;

	smooth = function( t )
		return 3 * t * t - 2 * t * t * t
	end;

	exit = function( t )
		return 1 - cos(t * halfpi)
	end;

	entrance = function( t )
		return sin(t * halfpi)
	end;

	ease = function( t )
		-- this is broken and idk why
		return 0; -- return u + d * ( 0.25 * (1 - t^3) + 0.3 * (1 - t^2) * t + 0.75 * (1 - t) * t^2 + t^3 )
	end;

	-- TODO: probably should add in all the default ones but why are they required?
}
