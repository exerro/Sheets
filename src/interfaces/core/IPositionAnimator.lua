
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPositionAnimator'
 -- @endif

 -- @print Including sheets.interfaces.IPositionAnimator

local function animateAttribute( self, label, setter, from, to, time, easing )
	easing = easing or SHEETS_DEFAULT_TRANSITION_EASING

	functionParameters.check( 3, "to", "number", to, "time", "number", time or 0, "easing", type( easing ) == "string" and "string" or "function", easing )

	local a = Animation():setRounded()
		:addKeyFrame( from, to, time or SHEETS_DEFAULT_TRANSITION_TIME, easing )
	self:addAnimation( label, setter, a )
	return a
end

local function animateElementInOrOut( self, mode, vertical, current, to, time )
	if not self.parent then
		return
	end

	local a = Animation():setRounded():addKeyFrame( current, to, time, mode == "in" and "entrance" or "exit" )

	if vertical then
		self:addAnimation( "y", self.setY, a )
	else
		self:addAnimation( "x", self.setX, a )
	end
	if mode == "exit" then
		function a.onFinish() self:remove() end
	end

	return a
end

IPositionAnimator = {}

function IPositionAnimator:animateX( to, time, easing )
	return animateAttribute( self, "x", self.setX, self.x, to, time, easing )
end

function IPositionAnimator:animateY( to, time, easing )
	return animateAttribute( self, "y", self.setY, self.y, to, time, easing )
end

function IPositionAnimator:animateZ( to, time, easing )
	return animateAttribute( self, "z", self.setZ, self.z, to, time, easing )
end

function IPositionAnimator:animateWidth( to, time, easing )
	return animateAttribute( self, "width", self.setWidth, self.width, to, time, easing )
end

function IPositionAnimator:animateHeight( to, time, easing )
	return animateAttribute( self, "height", self.setHeight, self.height, to, time, easing )
end

function IPositionAnimator:animateIn( side, to, time )
	side = side or "top"
	time = time or SHEETS_DEFAULT_TRANSITION_TIME

	functionParameters.check( 3, "side", "string", side, "to", "number", to or 0, "time", "number", time )

	if side == "top" then
		return animateElementInOrOut( self, "in", true, self.y, to or 0, time )
	elseif side == "left" then
		return animateElementInOrOut( self, "in", false, self.x, to or 0, time )
	elseif side == "right" then
		return animateElementInOrOut( self, "in", false, self.x, to or self.parent.width - self.width, time )
	elseif side == "bottom" then
		return animateElementInOrOut( self, "in", true, self.y, to or self.parent.height - self.height, time )
	else
		throw( IncorrectParameterException( "invalid side '" .. side .. "'", 2 ) )
	end
end

function IPositionAnimator:animateOut( side, to, time )
	side = side or "top"
	time = time or SHEETS_DEFAULT_TRANSITION_TIME

	functionParameters.check( 3, "side", "string", side, "to", "number", to or 0, "time", "number", time )

	if side == "top" then
		return animateElementInOrOut( self, "out", true, self.y, to or -self.height, time )
	elseif side == "left" then
		return animateElementInOrOut( self, "out", false, self.x, to or -self.width, time )
	elseif side == "right" then
		return animateElementInOrOut( self, "out", false, self.x, to or self.parent.width, time )
	elseif side == "bottom" then
		return animateElementInOrOut( self, "out", true, self.y, to or self.parent.height, time )
	else
		throw( IncorrectParameterException( "invalid side '" .. side .. "'", 2 ) )
	end
end
