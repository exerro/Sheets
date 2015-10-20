
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.animation.Animation'
 -- @endif

 -- @print Including sheets.animation.Animation

-- if you try to update the value being animated using an onFinish method, nothing will happen unless you set self.value to nil

local halfpi = math.pi / 2

local function easing_transition( u, d, t )
	return u + d * ( 3 * t * t - 2 * t * t * t )
end

local function easing_exit( u, d, t )
	return -d * math.cos(t * halfpi) + d + u
end

local function easing_entrance( u, d, t )
	return u + d * math.sin(t * halfpi)
end

class "Animation" {
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
	if easing == SHEETS_EASING_TRANSITION then
		easing = easing_transition
	elseif easing == SHEETS_EASING_EXIT then
		easing = easing_exit
	elseif easing == SHEETS_EASING_ENTRANCE then
		easing = easing_entrance
	end

	if type( initial ) ~= "number" then return error( "expected number initial, got " .. class.type( initial ) ) end
	if type( final ) ~= "number" then return error( "expected number final, got " .. class.type( final ) ) end
	if type( duration ) ~= "number" then return error( "expected number duration, got " .. class.type( duration ) ) end
	if easing and type( easing ) ~= "function" then return error( "expected function easing, got " .. class.type( easing ) ) end
	 
	local frame = KeyFrame( initial, final, duration, easing )
	self.frames[#self.frames + 1] = frame

	if #self.frames == 0 then
		self.value = frame.value
	end

	return self
end

function Animation:addPause( pause )
	pause = pause or 1
	if type( pause ) ~= "number" then return error( "expected number pause, got " .. class.type( pause ) ) end

	local p = Pause( pause )
	self.frames[#self.frames + 1] = p

	return self
end

function Animation:getLastAdded()
	return self.frames[#self.frames]
end

function Animation:update( dt )
	if type( dt ) ~= "number" then return error( "expected number dt, got " .. class.type( dt ) ) end
	
	if self.frames[1] then
		self.frames[1]:update( dt )
		self.value = self.frames[1].value or self.value -- the or self.value is because pauses don't have a value
		if self.rounded and self.value then
			self.value = math.floor( self.value + .5 )
		end
		if self.frames[1]:finished() then
			if type( self.frames[1].onFinish ) == "function" then
				self.frames[1].onFinish( self )
			end
			table.remove( self.frames, 1 )
		end
	end
end

function Animation:finished()
	return #self.frames == 0
end
