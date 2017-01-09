
 -- @once
 -- @print Including sheets.interfaces.IAttributeAnimator

local function animate_attribute( self, label, setter, from, to, time, easing )
	easing = easing or SHEETS_DEFAULT_TRANSITION_EASING

	parameters.check( 3, "to", "number", to, "time", "number", time or 0, "easing", type( easing ) == "string" and "string" or "function", easing )

	local a = Animation():set_rounded()
		:add_key_frame( from, to, time or SHEETS_DEFAULT_TRANSITION_TIME, easing )
	self:add_animation( label, setter, a )
	return a
end

local function animate_element_in_or_out( self, mode, vertical, current, to, time )
	if not self.parent then
		return
	end

	local a = Animation():set_rounded():add_key_frame( current, to, time, mode == "in" and "entrance" or "exit" )

	if vertical then
		self:add_animation( "y", self.setY, a )
	else
		self:add_animation( "x", self.setX, a )
	end

	if mode == "exit" then
		function a.on_finish() self:remove() end
	end

	return a
end

interface "IAttributeAnimator" {}

function IAttributeAnimator:animate_value( value, from, to, time, easing, rounded )
	easing = easing or SHEETS_DEFAULT_TRANSITION_EASING

	parameters.check( 5, "value", "string", value, "from", "number", from, "to", "number", to, "time", "number", time or 0, "easing", type( easing ) == "string" and "string" or "function", easing )

	local animation = ( rounded and Animation():set_rounded() or Animation() ):add_key_frame( from, to, time, easing )
	local setter = self["set" .. value:sub( 1, 1 ):upper() .. value:sub( 2 )]

	return self:add_animation( value, setter, animation )
end

function IAttributeAnimator:animateX( to, time, easing )
	return animate_attribute( self, "x", self.setX, self.x, to, time, easing )
end

function IAttributeAnimator:animateY( to, time, easing )
	return animate_attribute( self, "y", self.setY, self.y, to, time, easing )
end

function IAttributeAnimator:animateZ( to, time, easing )
	return animate_attribute( self, "z", self.setZ, self.z, to, time, easing )
end

function IAttributeAnimator:animate_width( to, time, easing )
	return animate_attribute( self, "width", self.set_width, self.width, to, time, easing )
end

function IAttributeAnimator:animate_height( to, time, easing )
	return animate_attribute( self, "height", self.set_height, self.height, to, time, easing )
end

function IAttributeAnimator:animate_in( side, to, time )
	side = side or "top"
	time = time or SHEETS_DEFAULT_TRANSITION_TIME

	parameters.check( 3, "side", "string", side, "to", "number", to or 0, "time", "number", time )

	if side == "top" then
		return animate_element_in_or_out( self, "in", true, self.y, to or 0, time )
	elseif side == "left" then
		return animate_element_in_or_out( self, "in", false, self.x, to or 0, time )
	elseif side == "right" then
		return animate_element_in_or_out( self, "in", false, self.x, to or self.parent.width - self.width, time )
	elseif side == "bottom" then
		return animate_element_in_or_out( self, "in", true, self.y, to or self.parent.height - self.height, time )
	else
		Exception.throw( IncorrectParameterException, "invalid side '" .. side .. "'", 2 )
	end
end

function IAttributeAnimator:animate_out( side, to, time )
	side = side or "top"
	time = time or SHEETS_DEFAULT_TRANSITION_TIME

	parameters.check( 3, "side", "string", side, "to", "number", to or 0, "time", "number", time )

	if side == "top" then
		return animate_element_in_or_out( self, "out", true, self.y, to or -self.height, time )
	elseif side == "left" then
		return animate_element_in_or_out( self, "out", false, self.x, to or -self.width, time )
	elseif side == "right" then
		return animate_element_in_or_out( self, "out", false, self.x, to or self.parent.width, time )
	elseif side == "bottom" then
		return animate_element_in_or_out( self, "out", true, self.y, to or self.parent.height, time )
	else
		Exception.throw( IncorrectParameterException, "invalid side '" .. side .. "'", 2 )
	end
end
