
 -- @once
 -- @print Including sheets.elements.Image

class "Image" extends "Sheet" {
	down = false;
	image = nil;
	fill = nil;
}

function Image:Image( x, y, img )
	if type( img ) == "string" then
		if fs.exists( img ) then
			local h = fs.open( img, "r" )
			if h then
				img = h.readAll()
				h.close()
			end
		end
		img = image.decode_paintutils( img )
	elseif type( img ) ~= "table" then
		parameters.check_constructor( self.class, 1, "image", "string", img ) -- definitely error
	end

	local width, height = #( img[1] or "" ), #img

	self.image = img
	return self:Sheet( x, y, width, height )
end

function Image:set_width() end
function Image:set_height() end

function Image:on_pre_draw()
	local shader = self.style:get( "shader." .. ( self.down and "pressed" or "default" ) )

	if not self.fill then
		self.fill = self.canvas:get_area( GRAPHICS_AREA_FILL )
	end

	image.apply( self.image, self.canvas )

	if shader then
		self.canvas:map_shader( self.fill, shader )
	end
end

function Image:on_mouse_event( event )
	if event:is( EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:set_changed()
	end

	if event.handled or not event:is_within_area( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( EVENT_MOUSE_DOWN ) and not self.down then
		self.down = true
		self:set_changed()
		event:handle()
	elseif event:is( EVENT_MOUSE_CLICK ) then
		if self.on_click then
			self:on_click( event.button, event.x, event.y )
		end
		event:handle()
	elseif event:is( EVENT_MOUSE_HOLD ) then
		if self.on_hold then
			self:on_hold( event.button, event.x, event.y )
		end
		event:handle()
	end
end

Style.add_to_template( Image, {
	["shader"] = false;
	["shader.pressed"] = false;
} )
