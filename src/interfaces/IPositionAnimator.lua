
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IPositionAnimator'
 -- @endif

 -- @print Including sheets.interfaces.IPositionAnimator

local function animateAttribute( self, label, setter, from, to, time, easing )
	if type( to ) ~= "number" then return error( "expected number to, got " .. class.type( to ) ) end
	if time and type( time ) ~= "number" then return error( "expected number time, got " .. class.type( time ) ) end

	local a = Animation():setRounded()
		:addKeyFrame( from, to, time or SHEETS_DEFAULT_TRANSITION_TIME, easing or SHEETS_DEFAULT_TRANSITION_EASING )
	self:addAnimation( label, setter, a )
	return a
end

local function animateElementInOrOut( self, mode, vertical, current, to, time )
	if time and type( time ) ~= "number" then return error( "expected number time, got " .. class.type( time ) ) end
	if to and type( to ) ~= "number" then return error( "expected number to, got " .. class.type( to ) ) end

	if not self.parent then
		return error( tostring( self ) .. " has no parent, cannot animate " .. mode )
	end

	local a = Animation():setRounded():addKeyFrame( current, to, time or SHEETS_DEFAULT_TRANSITION_TIME, mode == "in" and "entrance" or "exit" )

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

function IPositionAnimator:animateInLeft( to, time )
	return animateElementInOrOut( self, "in", false, self.x, to or 0, time )
end

function IPositionAnimator:animateOutLeft( to, time )
	return animateElementInOrOut( self, "out", false, self.x, to or -self.width, time )
end

function IPositionAnimator:animateInRight( to, time )
	return animateElementInOrOut( self, "in", false, self.x, to or self.parent.width - self.width, time )
end

function IPositionAnimator:animateOutRight( to, time )
	return animateElementInOrOut( self, "out", false, self.x, to or self.parent.width, time )
end

function IPositionAnimator:animateInTop( to, time )
	return animateElementInOrOut( self, "in", true, self.y, to or 0, time )
end

function IPositionAnimator:animateOutTop( to, time )
	return animateElementInOrOut( self, "out", true, self.y, to or -self.height, time )
end

function IPositionAnimator:animateInBottom( to, time )
	return animateElementInOrOut( self, "in", true, self.y, to or self.parent.height - self.height, time )
end

function IPositionAnimator:animateOutBottom( to, time )
	return animateElementInOrOut( self, "out", true, self.y, to or self.parent.height, time )
end
