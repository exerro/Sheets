
 -- @include components.active
 -- @include components.image

 -- @print including(elements.Image)

@class Image extends Sheet {
	down = false;
}

Image:add_components( 'active', 'image' )

function Image:Image( x, y, width, height, image )
	if type( width ) == "table" then -- TODO: improve surface type detection
		image = width
		width, height = image.width, image.height
	end

	self:Sheet( x, y, width, height )

	if image then
		self:set_image( image )
	else
		self.image = surface.create( self.width, self.height )
		self.image:clear( WHITE, WHITE, " " )
	end
end

function Image:draw( surface, x, y )
	surface:drawSurface( self.image, x, y, self.width, self.height )
	self.changed = false
end

function Image:on_mouse_event( event )
	if event:is( EVENT_MOUSE_UP ) and self.down and event.button == self.down then
		self.down = false
		self:set_active( false )

		return self:set_changed()
	end

	if event.handled or not event:is_within_area( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( EVENT_MOUSE_DOWN ) and not self.down then
		self.down = event.button
		self:set_active( true )
		self:set_changed()

		return event:handle( self )
	elseif event:is( EVENT_MOUSE_CLICK ) then
		if self.on_click then
			self:on_click( event.button, event.x, event.y )
		end

		return event:handle( self )
	elseif event:is( EVENT_MOUSE_HOLD ) and self.down and event.button == self.down then
		if self.on_hold then
			self:on_hold( event.button, event.x, event.y )
		end

		return event:handle( self )
	end
end
