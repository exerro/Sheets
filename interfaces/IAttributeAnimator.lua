
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IAttributeAnimator'
 -- @endif

 -- @print Including sheets.interfaces.IAttributeAnimator

local function animateAttribute( self, label, setter, from, to, time, easing )
	easing = easing or SHEETS_DEFAULT_TRANSITION_EASING

	parameters.check( 3, "to", "number", to, "time", "number", time or 0, "easing", type( easing ) == "string" and "string" or "function", easing )

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

interface "IAttributeAnimator" {}

function IAttributeAnimator:animateValue( value, from, to, time, easing, rounded )
	easing = easing or SHEETS_DEFAULT_TRANSITION_EASING

	parameters.check( 5, "value", "string", value, "from", "number", from, "to", "number", to, "time", "number", time or 0, "easing", type( easing ) == "string" and "string" or "function", easing )

	local animation = ( rounded and Animation():setRounded() or Animation() ):addKeyFrame( from, to, time, easing )
	local setter = self["set" .. value:sub( 1, 1 ):upper() .. value:sub( 2 )]

	return self:addAnimation( value, setter, animation )
end

function IAttributeAnimator:animateX( to, time, easing )
	return animateAttribute( self, "x", self.setX, self.x, to, time, easing )
end

function IAttributeAnimator:animateY( to, time, easing )
	return animateAttribute( self, "y", self.setY, self.y, to, time, easing )
end

function IAttributeAnimator:animateZ( to, time, easing )
	return animateAttribute( self, "z", self.setZ, self.z, to, time, easing )
end

function IAttributeAnimator:animateWidth( to, time, easing )
	return animateAttribute( self, "width", self.setWidth, self.width, to, time, easing )
end

function IAttributeAnimator:animateHeight( to, time, easing )
	return animateAttribute( self, "height", self.setHeight, self.height, to, time, easing )
end

function IAttributeAnimator:animateIn( side, to, time )
	side = side or "top"
	time = time or SHEETS_DEFAULT_TRANSITION_TIME

	parameters.check( 3, "side", "string", side, "to", "number", to or 0, "time", "number", time )

	if side == "top" then
		return animateElementInOrOut( self, "in", true, self.y, to or 0, time )
	elseif side == "left" then
		return animateElementInOrOut( self, "in", false, self.x, to or 0, time )
	elseif side == "right" then
		return animateElementInOrOut( self, "in", false, self.x, to or self.parent.width - self.width, time )
	elseif side == "bottom" then
		return animateElementInOrOut( self, "in", true, self.y, to or self.parent.height - self.height, time )
	else
		Exception.throw( IncorrectParameterException, "invalid side '" .. side .. "'", 2 )
	end
end

function IAttributeAnimator:animateOut( side, to, time )
	side = side or "top"
	time = time or SHEETS_DEFAULT_TRANSITION_TIME

	parameters.check( 3, "side", "string", side, "to", "number", to or 0, "time", "number", time )

	if side == "top" then
		return animateElementInOrOut( self, "out", true, self.y, to or -self.height, time )
	elseif side == "left" then
		return animateElementInOrOut( self, "out", false, self.x, to or -self.width, time )
	elseif side == "right" then
		return animateElementInOrOut( self, "out", false, self.x, to or self.parent.width, time )
	elseif side == "bottom" then
		return animateElementInOrOut( self, "out", true, self.y, to or self.parent.height, time )
	else
		Exception.throw( IncorrectParameterException, "invalid side '" .. side .. "'", 2 )
	end
end
