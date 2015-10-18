
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Application'
 -- @endif

 -- @print Including sheets.Application

local function childDrawSort( a, b )
	return a.z < b.z
end

class "Application" implements (IChildContainer) implements (IAnimationContainer)
{
	name = "UnNamed Application";
	terminateable = true;

	width = 0;
	height = 0;

	root = nil;
	screen = nil;
	terminal = term;

	running = true;
	theme = nil;
	changed = false;
}

-- need to add monitor support

Application.active = nil

function Application:Application( name )
	self.name = tostring( name or "UnNamed Application" )
	self.width, self.height = term.getSize()
	self.timers = {}

	self:IChildContainer()
	self:IAnimationContainer()

	self.theme = Theme()

	self.root = Sheet( 0, 0, self.width, self.height )
	self.screen = ScreenCanvas( self.width, self.height )

	self.root.canvas = self.screen
	self.meta.__add = self.addChild
end

function Application:setChanged( state )
	self.changed = state
end

function Application:stop()
	self.running = false
end

function Application:event( event, ... )
	Application.active = self

	if event == "timer" and timer.update( ... ) then
		Application.active = nil
		return
	end

	if event == "mouse_click" then

	elseif event == "mouse_up" then

	elseif event == "mouse_drag" then

	elseif event == "monitor_touch" then

	elseif event == "char" then

	elseif event == "key" then

	elseif event == "mouse_scroll" then

	elseif event == "paste" then

	elseif event == "term_resize" then
		self.width, self.height = term.getSize()
		self.root:setWidth( self.width )
		self.root:setHeight( self.height )
		self.root:handleParentResize()
	end
	Application.active = nil
end

function Application:update()
	local dt = timer.getDelta()

	Application.active = self

	timer.step()
	self:updateAnimations( dt )

	local c = {}
	for i = 1, #self.children do
		c[i] = self.children[i]
	end

	for i = #c, 1, -1 do
		c[i]:update( dt )
	end

	Application.active = nil
end

function Application:draw()
	if self.changed then
		local screen = self.screen

		screen:clear( self.theme:getField( self.class, "colour", "default" ) )

		local children = {}
		for i = 1, #self.children do
			children[i] = self.children[i]
		end
		table.sort( children, childDrawSort )

		for i = 1, #children do
			local child = children[i]
			child:draw()
			child.canvas:drawTo( screen, child.x, child.y )
		end

		self.changed = false

		screen:drawToTerminal( self.terminal )
	end
end

function Application:run()
	local t = timer.new( .05 )
	while self.running do
		local event = { coroutine.yield() }
		if event[1] == "timer" and event[2] == t then
			t = timer.new( .05 )
		elseif event[1] == "terminate" and self.terminateable then
			self:stop()
		end
		self:event( unpack( event ) )
		self:update()
		self:draw()
	end
end
