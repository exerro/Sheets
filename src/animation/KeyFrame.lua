
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.animation.KeyFrame'
 -- @endif

 -- @print Including sheets.animation.KeyFrame

 -- @define SHEETS_EASING_EXIT 0
 -- @define SHEETS_EASING_ENTRANCE 1
 -- @define SHEETS_EASING_TRANSITION 2

local function easing_transition( u, d, t )
	return u + d * ( 3 * t * t - 2 * t * t * t )
end

local function easing_exit( u, d, t )
	local t2 = t - 2
	return u + d * ( t * t * t * t * t2 * t2 * t2 * t2 )
end

local function easing_entrance( u, d, t )
	local t2 = t - 2
	return u + d * ( t * t * t2 * t2 )
end

class "KeyFrame" {
	easing = easing_transition;
	duration = 0;
	clock = 0;
	initial = 0;
	difference = 0;
	value = 0;
	rounded = false;
	onFinish = nil;
}

function KeyFrame:KeyFrame( initial, final, duration, easing )
	self.duration = duration
	self.initial = initial
	self.difference = final - initial
	self.easing = easing
	self.value = initial
end

function KeyFrame:update( dt )
	self.clock = math.min( math.max( self.clock + dt, 0 ), self.duration )

	if self.rounded then
		self.value = math.floor( self.easing( self.initial, self.difference, self.clock / self.duration ) + .5 )
	else
		self.value = self.easing( self.initial, self.difference, self.clock / self.duration )
	end

	if self.clock == self.duration and type( self.onFinish ) == "function" then
		self:onFinish()
	end
end

function KeyFrame:finished()
	return self.clock == self.duration
end
