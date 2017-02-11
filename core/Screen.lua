
 -- @once
 -- @print Including sheets.core.Screen

class "Screen"
	implements "IChildContainer"
	implements "ITagged"
	implements "ISize"
{
	parent = nil;

	-- internal
	terminals = {};
	monitors = {};

	canvas = nil;
	changed = true;
	values = nil;
}

function Screen:Screen( application, width, height )
	self.parent = application
	self.terminals = {}
	self.monitors = {}
	self.canvas = ScreenCanvas( width, height )
	self.application = application
	self.values = ValueHandler( self )

	self:ICollatedChildren()
	self:IChildContainer()
	self:ITagged()
	self:ISize()

	self:set_width( width )
	self:set_height( height )
end

function Screen:gets_term_events()
	for i = 1, #self.terminals do
		if self.terminals[i] == term then
			return true
		end
	end
	return false
end

function Screen:set_changed( state )
	self.changed = state ~= false
	if state ~= false then -- must have a parent Application
		self.parent.changed = true
	end
	return self
end

function Screen:add_monitor( side )
	parameters.check( 1, "side", "string", side )

	if peripheral.getType( side ) ~= "monitor" then
		throw( IncorrectParameterException, "expected monitor on side '" .. side .. "', got " .. peripheral.getType( side ), 2 )
	end

	local mon = peripheral.wrap( side )
	self.monitors[side] = mon

	return self:add_terminal( mon )
end

function Screen:remove_monitor( side )
	parameters.check( 1, "side", "string", side )

	local mon = self.monitors[side]
	if mon then
		self.monitors[side] = nil
		self:remove_terminal( mon )
	end

	return self
end

function Screen:uses_monitor( side )
	return self.monitors[side] ~= nil
end

function Screen:add_terminal( t )
	parameters.check( 1, "terminal", "table", t )

	self.terminals[#self.terminals + 1] = t
	self.canvas:reset()

	return self:set_changed()
end

function Screen:remove_terminal( t )
	parameters.check( 1, "terminal", "table", t )

	for i = #self.terminals, 1, -1 do
		if self.terminals[i] == t then
			self:set_changed()
			return table.remove( self.terminals, i )
		end
	end

	return self
end

function Screen:draw()
	if self.changed then

		local canvas = self.canvas
		local children = {}
		local cx, cy, cc

		canvas:clear()

		for i = 1, #self.children do
			children[i] = self.children[i]
		end

		for i = 1, #children do
			local child = children[i]

			if child:is_visible() then
				child:draw()
				child.canvas:draw_to( canvas, child.x, child.y )

				if child.cursor_active then
					cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
				end
			end
		end

		canvas:draw_to_terminals( self.terminals )

		self.changed = false
		for i = 1, #self.terminals do
			if cx then
				self.terminals[i].setCursorPos( cx + 1, cy + 1 )
				self.terminals[i].setTextColour( cc )
				self.terminals[i].setCursorBlink( true )
			else
				self.terminals[i].setCursorBlink( false )
			end
		end
	end
end

function Screen:handle( event )
	local c = {}
	local children = self.children
	for i = 1, #children do
		c[i] = children[i]
	end

	if event:type_of( MouseEvent ) then
		local within = event:is_within_area( 0, 0, self.width, self.height )
		for i = #c, 1, -1 do
			c[i]:handle( event:clone( c[i].x, c[i].y, within ) )
		end
	else
		for i = #c, 1, -1 do
			c[i]:handle( event )
		end
	end
end

function Screen:update( dt )
	local children = {}

	self.values:update( dt )

	for i = 1, #self.children do
		children[i] = self.children[i]
	end

	for i = 1, #children do
		children[i]:update( dt )
	end
end
