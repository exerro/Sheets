
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.Image'
 -- @endif

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
		img = image.decodePaintutils( img )
	elseif type( img ) ~= "table" then
		parameters.checkConstructor( self.class, 1, "image", "string", img ) -- definitely error
	end

	local width, height = #( img[1] or "" ), #img

	self.image = img
	return self:Sheet( x, y, width, height )
end

function Image:setWidth() end
function Image:setHeight() end

function Image:onPreDraw()
	local shader = self.style:getField( "shader." .. ( self.down and "pressed" or "default" ) )

	if not self.fill then
		self.fill = self.canvas:getArea( GRAPHICS_AREA_FILL )
	end

	image.apply( self.image, self.canvas )

	if shader then
		self.canvas:mapShader( self.fill, shader )
	end
end

function Image:onMouseEvent( event )
	if event:is( SHEETS_EVENT_MOUSE_UP ) and self.down then
		self.down = false
		self:setChanged()
	end

	if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
		return
	end

	if event:is( SHEETS_EVENT_MOUSE_DOWN ) and not self.down then
		self.down = true
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

Style.addToTemplate( Image, {
	["shader"] = false;
	["shader.pressed"] = false;
} )
