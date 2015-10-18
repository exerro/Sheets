
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Application'
 -- @endif

 -- @print Including sheets.Application

class "Application" implements (IChildContainer) implements (IAnimation)
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

	mouse = {};
	keys = {};
}

-- need to add monitor support

Application.active = nil

function Application:Application( name )
	self.name = tostring( name or "UnNamed Application" )
	self.width, self.height = term.getSize()
	self.timers = {}

	self:IChildContainer()
	self:IAnimation()

	self.theme = Theme()

	self.screen = ScreenCanvas( self.width, self.height )

	self.meta.__add = self.addChild
end

function Application:setChanged( state )
	self.changed = state
end

function Application:addChild( child )
	-- @if SHEETS_TYPE_CHECK
		if not class.typeOf( child, View ) then return error( "expected View child, got " .. class.type( child ) ) end
	-- @endif

	if child.parent then
		child.parent:removeChild( child )
	end

	self:setChanged( true )
	child.parent = self
	child:setTheme( self.theme )
	self.children[#self.children + 1] = child
	return child
end

function Application:stop()
	self.running = false
end

function Application:event( event, ... )
	Application.active = self

	local params = { ... }

	if event == "timer" and timer.update( ... ) then
		Application.active = nil
		return
	end

	local children = {}
	for i = 1, #self.children do
		children[i] = self.children[i]
	end

	local function handle( e )
		if e:typeOf( MouseEvent ) then
			for i = #children, 1, -1 do
				children[i]:handle( e:clone( children[i].x, children[i].y, true ) )
			end
		else
			for i = #children, 1, -1 do
				children[i]:handle( e )
			end
		end
	end

	if event == "mouse_click" then
		self.mouse = {
			x = params[2] - 1;
			y = params[3] - 1;
			down = true;
			timer = os.startTimer( 1 );
			moved = false;
			time = os.clock();
			button = params[1];
		}

		handle( MouseEvent( SHEETS_EVENT_MOUSE_DOWN, params[2] - 1, params[3] - 1, params[1], true ) )

	elseif event == "mouse_up" then
		handle( MouseEvent( SHEETS_EVENT_MOUSE_UP, params[2] - 1, params[3] - 1, params[1], true ) )

		self.mouse.down = false
		os.cancelTimer( self.mouse.timer )

		if not self.mouse.moved and os.clock() - self.mouse.time < 1 and params[1] == self.mouse.button then
			handle( MouseEvent( SHEETS_EVENT_MOUSE_CLICK, params[2] - 1, params[3] - 1, params[1], true ) )
		end

	elseif event == "mouse_drag" then
		handle( MouseEvent( SHEETS_EVENT_MOUSE_DRAG, params[2] - 1, params[3] - 1, params[1], true ) )

		self.mouse.moved = true
		os.cancelTimer( self.mouse.timer )

	elseif event == "mouse_scroll" then
		handle( MouseEvent( SHEETS_EVENT_MOUSE_SCROLL, params[2] - 1, params[3] - 1, params[1], true ) )

	elseif event == "monitor_touch" then
		handle( MouseEvent( SHEETS_EVENT_MOUSE_CLICK, params[2] - 1, params[3] - 1, params[1] ) )

	elseif event == "chatbox_something" then
		handle( TextEvent( SHEETS_EVENT_VOICE, params[1] ) )

	elseif event == "char" then
		handle( TextEvent( SHEETS_EVENT_TEXT, params[1] ) )

	elseif event == "paste" then
		handle( TextEvent( SHEETS_EVENT_PASTE, params[1] ) )

	elseif event == "key" then
		handle( TextEvent( SHEETS_EVENT_KEY_DOWN, params[1], self.keys ) )

	elseif event == "key_up" then
		handle( TextEvent( SHEETS_EVENT_KEY_UP, params[1], self.keys ) )

	elseif event == "term_resize" then
		self.width, self.height = term.getSize()
		self.root:setWidth( self.width )
		self.root:setHeight( self.height )
		self.root:handleParentResize()

	elseif event == "timer" then
		if params[1] == self.mouse.timer then
			handle( MouseEvent( SHEETS_EVENT_MOUSE_HOLD, self.mouse.x, self.mouse.y, self.mouse.button, true ) )
		else
			handle( TimerEvent( params[1] ) )
		end

	else
		handle( MiscEvent( event, ... ) )
	end

	Application.active = nil
end

function Application:update()

	Application.active = self

	local dt = timer.getDelta()
	local c = {}

	timer.step()
	self:updateAnimations( dt )

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
	local t = timer.new( 0 )
	while self.running do
		local event = { coroutine.yield() }
		if event[1] == "timer" and event[2] == t then
			t = timer.new( .05 )
			self:update()
		elseif event[1] == "terminate" and self.terminateable then
			self:stop()
		else
			self:event( unpack( event ) )
		end
		self:draw()
	end
end
