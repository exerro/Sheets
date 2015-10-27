
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.RippleButton'
 -- @endif

 -- @print Including sheets.RippleButton

class "RippleButton" extends "Sheet" implements (IHasText) {
	down = false;
	ripple = false;
	ripple_x = 0;
	ripple_y = 0;
	ripple_down = 0;
}

function RippleButton:RippleButton( x, y, width, height, text )
	self.text = text
	return self:Sheet( x, y, width, height )
end

function RippleButton:setInnerRippleRadius( radius )
	self.inner_radius = radius
	return self:setChanged()
end

function RippleButton:setOuterRippleRadius( radius )
	self.outer_radius = radius
	return self:setChanged()
end

function RippleButton:beginRippleAnimation()
	local x, y = self.ripple_x, self.ripple_y
	local l = math.sqrt( math.max( x, self.width - x ) ^ 2 + math.max( y, self.height - y ) ^ 2 )
	local a = self:addAnimation( "ripple-outer", self.setOuterRippleRadius, Animation():setRounded()
		:addKeyFrame( 0, l, .5, "entrance" ) )
	self:stopAnimation "ripple-inner"
	return a
end

function RippleButton:stopRippleAnimation()
	local x, y = self.ripple_x, self.ripple_y
	local l = math.sqrt( math.max( x, self.width - x ) ^ 2 + math.max( y, self.height - y ) ^ 2 )
	local a = self:addAnimation( "ripple-inner", self.setInnerRippleRadius, Animation():setRounded()
		:addPause( math.max( 0, .3 - os.clock() + self.ripple_down ) )
		:addKeyFrame( 0, l, .5, "entrance" ) )

	function a.onFinish()
		self.ripple = false
	end

	return a
end

function RippleButton:onPreDraw()
	self.canvas:clear( self.theme:getField( self.class, "colour", "default" ) )
	self:drawText( self.down and "pressed" or "default" )

	local canvas = self.canvas

	local rbc, rtc = self.theme:getField( self.class, "colour", "ripple" ), self.theme:getField( self.class, "textColour", "ripple" )

	if self.ripple then
		local circle
		local outer = canvas:getArea( GRAPHICS_AREA_CCIRCLE, self.ripple_x, self.ripple_y, self.outer_radius )

		if self.inner_radius > 0 then
			circle = outer - canvas:getArea( GRAPHICS_AREA_CCIRCLE, self.ripple_x, self.ripple_y, self.inner_radius )
		else
			circle = outer
		end

		canvas:mapShader( circle, function( bc, tc, char )
			return rbc, rtc, char
		end )
	end
end

function RippleButton:onMouseEvent( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:setChanged()
		self:stopRippleAnimation()
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		self.down = true

		self.ripple_x = event.x
		self.ripple_y = event.y
		self.ripple_down = os.clock()
		self.ripple = true

		self:setInnerRippleRadius( 0 )
		self:setOuterRippleRadius( 0 )
		self:beginRippleAnimation()
		self:setChanged()
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) then
		if self.onClick then
			self:onClick( event.button, event.x, event.y )
		end
		event:handle()
	elseif event:is( SHEETS_EVENT_MOUSE_HOLD ) then
		if self.onHold then
			self:onHold( event.button, event.x, event.y )
		end
		event:handle()
	end
end

Theme.addToTemplate( RippleButton, "colour", {
	default = CYAN;
	ripple = LIGHTBLUE;
} )
Theme.addToTemplate( RippleButton, "textColour", {
	default = WHITE;
	pressed = WHITE;
	ripple = WHITE;
} )

Theme.addToTemplate( RippleButton, "horizontal-alignment", {
	default = ALIGNMENT_CENTRE;
	pressed = ALIGNMENT_CENTRE;
} )
Theme.addToTemplate( RippleButton, "vertical-alignment", {
	default = ALIGNMENT_CENTRE;
	pressed = ALIGNMENT_CENTRE;
} )
