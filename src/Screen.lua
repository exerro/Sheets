
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Screen'
 -- @endif

 -- @print Including sheets.Screen

class "Screen"
	implements "IAnimation"
	implements "IChildContainer"
	implements "ISize"
{
	terminals = {};
	monitors = {};

	canvas = nil;
	parent = nil;
	changed = true;
}

function Screen:Screen( application, width, height )
	self.parent = application
	self.terminals = {}
	self.monitors = {}
	self.canvas = ScreenCanvas( width, height )
	self.width = width
	self.height = height
end

function Screen:setChanged( state )
	self.changed = state ~= false
	if state ~= false then -- must have a parent Application
		self.parent.changed = true
	end
	return self
end

function Screen:addMonitor( side )
	functionParameters.check( 1, "side", "string", side )

	if peripheral.getType( side ) ~= "monitor" then
		throw( IncorrectParameterException, "expected monitor on side '" .. side .. "', got " .. peripheral.getType( side ), 2 )
	end

	local mon = peripheral.wrap( side )
	self.monitors[side] = mon

	return self:addTerminal( mon )
end

function Screen:removeMonitor( side )
	functionParameters.check( 1, "side", "string", side )

	local mon = self.monitors[side]
	if mon then
		self.monitors[side] = nil
		self:removeTerminal( mon )
	end
end

function Screen:usesMonitor( side )
	return self.monitors[side] ~= nil
end

function Screen:addTerminal( t )
	functionParameters.check( 1, "terminal", "table", t )
	self.terminals[#self.terminals + 1] = t
	return self:setChanged()
end

function Screen:removeTerminal( t )
	functionParameters.check( 1, "terminal", "table", t )

	for i = #self.terminals, 1, -1 do
		if self.terminals[i] == t then
			self:setChanged()
			return table.remove( self.terminals, i )
		end
	end
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

			if child:isVisible() then
				child:draw()
				child.canvas:drawTo( canvas, child.x, child.y )
			
				if child.cursor_active then
					cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
				end
			end
		end

		canvas:drawToTerminals( self.terminals )

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

	if event:typeOf( MouseEvent ) then
		local within = event:isWithinArea( 0, 0, self.width, self.height )
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
	for i = 1, #self.children do
		children[i] = self.children[i]
	end
	for i = 1, #children do
		children[i]:update( dt )
	end
end
