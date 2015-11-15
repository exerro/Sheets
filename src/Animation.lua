
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Animation'
 -- @endif

 -- @print Including sheets.Animation

local sin, cos = math.sin, math.cos
local halfpi = math.pi / 2

local function easing_transition( u, d, t )
	return u + d * ( 3 * t * t - 2 * t * t * t )
end

local function easing_exit( u, d, t )
	return -d * cos(t * halfpi) + d + u
end

local function easing_entrance( u, d, t )
	return u + d * sin(t * halfpi)
end

class "Animation" {
	frame = 1;
	frames = {};
	value = nil;
	rounded = false;
}

function Animation:Animation()
	self.frames = {}
end

function Animation:setRounded( value )
	self.rounded = value ~= false
	return self
end

function Animation:addKeyFrame( initial, final, duration, easing )
	duration = duration or .5
	easing = easing or easing_transition

	if not easing or easing == "transition" then
		easing = easing_transition
	elseif easing == "entrance" then
		easing = easing_entrance
	elseif easing == "exit" then
		easing = easing_exit
	end

	parameters.check( 4,
		"initial", "number", initial,
		"final", "number", final,
		"duration", "number", duration,
		"easing", "function", easing
	)

	local frame = {
		ease = true;
		clock = 0;
		duration = duration;
		initial = initial;
		difference = final - initial;
		easing = easing;
	}

	self.frames[#self.frames + 1] = frame

	if #self.frames == 1 then
		self.value = initial
	end

	return self
end

function Animation:addPause( pause )
	pause = pause or 1
	parameters.check( 1, "pause", "number", pause )

	local frame = {
		clock = 0;
		duration = pause;
	}

	self.frames[#self.frames + 1] = frame

	return self
end

function Animation:frameFinished()
	if type( self.onFrameFinished ) == "function" then
		self:onFrameFinished( self.frame )
	end

	self.frame = self.frame + 1

	if not self.frames[self.frame] and type( self.onFinish ) == "function" then
		self:onFinish()
	end
end

function Animation:update( dt )
	parameters.check( 1, "dt", "number", dt )
	
	local frame = self.frames[self.frame]

	if frame then
		frame.clock = math.min( frame.clock + dt, frame.duration )

		if frame.ease then

			local value = frame.easing( frame.initial, frame.difference, frame.clock / frame.duration )
			if self.rounded then
				value = math.floor( value + .5 )
			end

			self.value = value

			if frame.clock >= frame.duration then
				self:frameFinished()
			end

		end

		if frame.clock >= frame.duration then
			self:frameFinished()
		end
	end
end

function Animation:finished()
	return not self.frames[self.frame]
end
