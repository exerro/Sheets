
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.elements.ScrollContainer'
 -- @endif

 -- @print Including sheets.elements.ScrollContainer

class "ScrollContainer" extends "Sheet" {
	scrollX = 0;
	scrollY = 0;

	horizontalPadding = 0;
	verticalPadding = 0;

	heldScrollbar = false;
	down = false;
}

function ScrollContainer:ScrollContainer( x, y, width, height, element )
	if class.typeOf( x, Sheet ) then
		element = x
		x, y, width, height = x.x, x.y, x.width, x.height
		element.x, element.y = 0, 0
	end

	if type( x ) ~= "number" then return error( "element attribute #1 'x' not a number (" .. class.type( x ) .. ")", 2 ) end
	if type( y ) ~= "number" then return error( "element attribute #2 'y' not a number (" .. class.type( y ) .. ")", 2 ) end
	if type( width ) ~= "number" then return error( "element attribute #3 'width' not a number (" .. class.type( width ) .. ")", 2 ) end
	if type( height ) ~= "number" then return error( "element attribute #4 'height' not a number (" .. class.type( height ) .. ")", 2 ) end

	self:Sheet( x, y, width, height )

	if element then
		if class.typeOf( element, Sheet ) then
			self:addChild( element )
		else
			return error( "expected Sheet element, got " .. class.type( element ), 2 )
		end
	end
end

function ScrollContainer:setScrollX( scroll )
	if type( scroll ) ~= "number" then return error( "expected number scroll, got " .. class.type( scroll ) ) end

	self.scrollX = scroll
	self:setChanged()
end

function ScrollContainer:setScrollY( scroll )
	if type( scroll ) ~= "number" then return error( "expected number scroll, got " .. class.type( scroll ) ) end

	self.scrollY = scroll
	self:setChanged()
end

function ScrollContainer:getContentWidth()
	local width = self.horizontalPadding
	local children = self.children

	for i = 1, #self.children do
		local childWidth = children[i].x + children[i].width + self.horizontalPadding
		if childWidth > width then
			width = childWidth
		end
	end

	return width
end

function ScrollContainer:getContentHeight()
	local height = self.verticalPadding
	local children = self.children

	for i = 1, #self.children do
		local childWidth = children[i].y + children[i].height + self.verticalPadding
		if childWidth > height then
			height = childWidth
		end
	end

	return height
end

function ScrollContainer:getDisplayWidth( h, v )
	return v and self.width - 1 or self.width
end

function ScrollContainer:getDisplayHeight( h, v )
	return h and self.height - 1 or self.height
end

function ScrollContainer:getActiveScrollbars( cWidth, cHeight )
	if cWidth > self.width or cHeight > self.height then
		return cWidth >= self.width, cHeight >= self.height
	end
	return false, false
end

function ScrollContainer:getScrollbarSizes( cWidth, cHeight, horizontal, vertical )
	return math.floor( self:getDisplayWidth( horizontal, vertical ) / cWidth * self:getDisplayWidth( horizontal, vertical ) + .5 ), math.floor( self:getDisplayHeight( horizontal, vertical ) / cHeight * self.height + .5 )
end

function ScrollContainer:getScrollbarPositions( cWidth, cHeight, horizontal, vertical )
	return math.floor( self.scrollX / cWidth * self:getDisplayWidth( horizontal, vertical ) + .5 ), math.floor( self.scrollY / cHeight * self.height + .5 )
end

function ScrollContainer:draw()
	if self.changed then

		local children = self.children
		local cx, cy, cc
		local ox, oy = self.scrollX, self.scrollY

		self:resetCursorBlink()

		if self.onPreDraw then
			self:onPreDraw()
		end

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( self.canvas, child.x - ox, child.y - oy )

			if child.cursor_active then
				cx, cy, cc = child.x + child.cursor_x - ox, child.y + child.cursor_y - oy, child.cursor_colour
			end
		end

		if cx then
			self:setCursorBlink( cx, cy, cc )
		end

		if self.onPostDraw then
			self:onPostDraw()
		end

		self.changed = false
	end
end

function ScrollContainer:handle( event )
	local c = {}
	local children = self.children
	for i = 1, #children do
		c[i] = children[i]
	end

	if self.down and event:is( SHEETS_EVENT_MOUSE_UP ) then
		self.down = false
		self.heldScrollbar = false
		self:setChanged()
		event:handle()
	elseif self.down and event:is( SHEETS_EVENT_MOUSE_DRAG ) then
		local cWidth, cHeight = self:getContentWidth(), self:getContentHeight()
		local h, v = self:getActiveScrollbars( cWidth, cHeight )

		if self.heldScrollbar == "h" then
			self.scrollX = math.max( math.min( math.floor( ( event.x - self.down ) / self:getDisplayWidth( h, v ) * cWidth ), cWidth - self:getDisplayWidth( h, v ) ), 0 )
			self:setChanged()
			event:handle()
		elseif self.heldScrollbar == "v" then
			self.scrollY = math.max( math.min( math.floor( ( event.y - self.down ) / self.height * cHeight ), cHeight - self:getDisplayHeight( h, v ) ), 0 )
			self:setChanged()
			event:handle()
		end
	end

	if event:typeOf( MouseEvent ) and not event.handled and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then
		local cWidth, cHeight = self:getContentWidth(), self:getContentHeight()
		local h, v = self:getActiveScrollbars( cWidth, cHeight )

		if event:is( SHEETS_EVENT_MOUSE_DOWN ) then
			if event.x == self.width - 1 and v then
				local px, py = self:getScrollbarPositions( cWidth, cHeight, h, v )
				local sx, sy = self:getScrollbarSizes( cWidth, cHeight, h, v )
				local down = event.y

				if down < px then
					self.scrollY = math.floor( down / self.height * cHeight )
					down = 0
				elseif down >= px + sx then
					self.scrollY = math.floor( ( down - sy + 1 ) / self.height * cHeight )
					down = sy - 1
				else
					down = down - py
				end

				self.heldScrollbar = "v"
				self.down = down
				self:setChanged()
				event:handle()
			elseif event.y == self.height - 1 and h then
				local px, py = self:getScrollbarPositions( cWidth, cHeight, h, v )
				local sx, sy = self:getScrollbarSizes( cWidth, cHeight, h, v )
				local down = event.x

				if down < px then
					self.scrollX = math.floor( down / self:getDisplayWidth( h, v ) * cWidth )
					down = 0
				elseif down >= px + sx then
					self.scrollX = math.floor( ( down - sx + 1 ) / self:getDisplayWidth( h, v ) * cWidth )
					down = sx - 1
				else
					down = down - px
				end

				self.heldScrollbar = "h"
				self.down = down
				self:setChanged()
				event:handle()
			end
		elseif event:is( SHEETS_EVENT_MOUSE_SCROLL ) then
			if v then
				self:setScrollY( math.max( math.min( self.scrollY + event.button, cHeight - self:getDisplayHeight( h, v ) ), 0 ) )
			elseif h then
				self:setScrollX( math.max( math.min( self.scrollX + event.button, cWidth - self:getDisplayWidth( h, v ) ), 0 ) )
			end
		elseif event:is( SHEETS_EVENT_MOUSE_CLICK ) or event:is( SHEETS_EVENT_MOUSE_HOLD ) then
			event:handle()
		end
	end

	if event:typeOf( MouseEvent ) then
		local within = event:isWithinArea( 0, 0, self.width, self.height )
		for i = #c, 1, -1 do
			c[i]:handle( event:clone( c[i].x + self.scrollX, c[i].y + self.scrollY, within ) )
		end
	else
		for i = #c, 1, -1 do
			c[i]:handle( event )
		end
	end

	if event:typeOf( MouseEvent ) then
		if event:is( EVENT_MOUSE_PING ) and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then
			event.button[#event.button + 1] = self
		end
		self:onMouseEvent( event )
	elseif event:typeOf( KeyboardEvent ) and self.handlesKeyboard and self.onKeyboardEvent then
		self:onKeyboardEvent( event )
	elseif event:typeOf( TextEvent ) and self.handlesText and self.onTextEvent then
		self:onTextEvent( event )
	end
end

function ScrollContainer:onPreDraw()
	self.canvas:clear( self.theme:getField( self.class, "colour", "default" ) )
end

function ScrollContainer:onPostDraw()
	local cWidth, cHeight = self:getContentWidth(), self:getContentHeight()
	local h, v = self:getActiveScrollbars( cWidth, cHeight )
	if h or v then
		local px, py = self:getScrollbarPositions( cWidth, cHeight, h, v )
		local sx, sy = self:getScrollbarSizes( cWidth, cHeight, h, v )

		if h then
			local c1 = self.theme:getField( self.class, "horizontal-bar", "default" )
			local c2 = self.heldScrollbar == "h" and
					   self.theme:getField( self.class, "horizontal-bar", "active" )
					or self.theme:getField( self.class, "horizontal-bar", "bar" )

			self.canvas:mapColour( self.canvas:getArea( GRAPHICS_AREA_HLINE, 0, self.height - 1, self:getDisplayWidth( h, v ) ), c1 )
			self.canvas:mapColour( self.canvas:getArea( GRAPHICS_AREA_HLINE, px, self.height - 1, sx ), c2 )
		end
		if v then
			local c1 = self.theme:getField( self.class, "vertical-bar", "default" )
			local c2 = self.heldScrollbar == "v" and
					   self.theme:getField( self.class, "vertical-bar", "active" )
					or self.theme:getField( self.class, "vertical-bar", "bar" )

			self.canvas:mapColour( self.canvas:getArea( GRAPHICS_AREA_VLINE, self.width - 1, 0, self.height ), c1 )
			self.canvas:mapColour( self.canvas:getArea( GRAPHICS_AREA_VLINE, self.width - 1, py, sy ), c2 )
		end
	end
end

Theme.addToTemplate( ScrollContainer, "colour", {
	default = WHITE;
} )

Theme.addToTemplate( ScrollContainer, "horizontal-bar", {
	default = GREY;
	bar = LIGHTGREY;
	active = LIGHTBLUE;
} )

Theme.addToTemplate( ScrollContainer, "vertical-bar", {
	default = GREY;
	bar = LIGHTGREY;
	active = LIGHTBLUE;
} )
