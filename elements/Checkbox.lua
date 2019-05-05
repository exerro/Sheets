
 -- @include components.active
 -- @include components.colour
 -- @include components.text
 -- @include components.toggled
 -- @include components.unisize
 -- @include interfaces.IToggleable

 -- @print including(elements.Checkbox)

@class Checkbox extends Sheet implements IToggleable {
	down = false;
}

Checkbox:add_components( 'active', 'colour', 'text', 'toggled', 'unisize' )

function Checkbox:Checkbox( x, y )
	self:Sheet( x, y, 1, 1 )

	self:set_colour( GREY, true )
	self:set_text_colour( WHITE, true )
	self:set_toggled_colour( GREY, true )
	self:set_toggled_text_colour( WHITE, true )
	self:set_active_colour( LIGHTGREY, true )
	self:set_active_text_colour( WHITE, true )
	self:set_text " "
	self:set_toggled_text "x"
	self:set_active_text "!toggled & toggled_text | text"

	self.width = 1;
	self.height = 1;
	self.max_width = 1;
	self.min_width = 1;
	self.max_height = 1;
	self.min_height = 1;
end

function Checkbox:toggle()
	self:set_toggled( not self.toggled )

	if self.toggled and self.on_toggled then
		self:on_toggled()
	end
	if not self.toggled and self.on_untoggled then
		self:on_untoggled()
	end
	if self.on_toggle then
		self:on_toggle( self.toggled )
	end
end

-- TODO: make these better
function Checkbox:set_width() end
function Checkbox:set_height() end
function Checkbox:set_min_width() end
function Checkbox:set_min_height() end
function Checkbox:set_max_width() end
function Checkbox:set_max_height() end

function Checkbox:draw( surface, x, y )
	local bcol = self.colour
	local tcol = self.text_colour
	local char = self.text

	if self.toggled then
		bcol = self.toggled_colour
		tcol = self.toggled_text_colour
		char = self.toggled_text
	end

	if self.down then
		bcol = self.active_colour
		tcol = self.active_text_colour
		char = self.active_text
	end

	surface:fillRect( x, y, self.width, self.height, bcol, tcol, char )
	self.changed = false
end

function Checkbox:on_mouse_event( event )
	if event:is( EVENT_MOUSE_UP ) and self.down and event.button == self.down then
		self.down = false
		self:set_active( false )

		return self:set_changed()
	end

	if event.handled or event.x ~= 0 or event.y ~= 0 or not event.within then
		return
	end

	if event:is( EVENT_MOUSE_DOWN ) and not self.down then
		self.down = event.button
		self:set_active( true )
		self:set_changed()

		return event:handle( self )
	elseif event:is( EVENT_MOUSE_CLICK ) then
		self:toggle()

		return event:handle( self )
	--[[elseif event:is( EVENT_MOUSE_HOLD ) and self.down and event.button == self.down then
		if self.on_hold then
			self:on_hold( event.button, event.x, event.y )
		end

		return event:handle( self )]]
	end
end
