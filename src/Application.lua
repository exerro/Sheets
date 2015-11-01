
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Application'
 -- @endif

 -- @print Including sheets.Application

local function exceptionHandler( e )
	return error( "An uncaught " .. e.name .. " exception was thrown:\n" .. tostring( e ), 0 )
end

class "Application" implements (IChildContainer) implements (IAnimation)
{
	name = "UnNamed Application";
	path = "";
	terminateable = true;

	viewportX = 0;
	viewportY = 0;

	width = 0;
	height = 0;

	screen = nil;

	terminals = { term };
	monitor_sides = {};

	running = true;

	changed = true;

	mouse = nil;
	keys = {};
}

function Application:Application()
	self.width, self.height = term.getSize()

	self:IChildContainer()
	self:IAnimation()

	self.screen = ScreenCanvas( self.width, self.height )
end

function Application:stop()
	self.running = false
	return self
end

function Application:setViewportX( x )
	functionParameters.check( 1, "x", "number", x )

	self.viewportX = x
	self:setChanged()
	return self
end

function Application:setViewportY( y )
	functionParameters.check( 1, "y", "number", y )
	
	self.viewportY = y
	self:setChanged()
	return self
end

function Application:transitionViewport( x, y )
	functionParameters.check( 1, "x", "number", x )
	functionParameters.check( 1, "y", "number", y )
	
	local ax, ay -- the animations defined later on
	local dx = x and math.abs( x - self.viewportX ) or 0
	local dy = y and math.abs( y - self.viewportY ) or 0

	local xt = .4 * dx / self.width
	if dx > 0 then
		local ax = self:addAnimation( "viewportX", self.setViewportX, Animation():setRounded()
			:addKeyFrame( self.viewportX, x, xt, SHEETS_EASING_TRANSITION ) )
	end
	if dy > 0 then
		local ay = self:addAnimation( "viewportY", self.setViewportY, Animation():setRounded()
			:addPause( xt )
			:addKeyFrame( self.viewportY, y, .4 * dy / self.height, SHEETS_EASING_TRANSITION ) )
	end
	return ax, ay
end

function Application:transitionToView( view )
	functionParameters.check( 1, "view", View, view )
	
	if view.parent == self then
		return self:transitionViewport( view.x, view.y )
	else
		throw( IncorrectParameterException( "View given is not a part of application '" .. self.name .. "'", 2 ) )
	end
end

function Application:addTerminal( t )
	functionParameters.check( 1, "redirect", "table", t )

	self.terminals[#self.terminals + 1] = t
	self.screen:reset()
	return self
end

function Application:removeTerminal( t )
	for i = #self.terminals, 1, -1 do
		if self.terminals[i] == t then
			table.remove( self.terminals, i )
			break
		end
	end
	return self
end

function Application:addMonitor( side )
	functionParameters.check( 1, "side", "string", side )

	if peripheral.getType( side ) == "monitor" then
		local r = peripheral.wrap( side )
		self.terminals[#self.terminals + 1] = r
		self.monitor_sides[side] = r
		return self
	else
		return error( "no monitor on side " .. tostring( side ) )
	end
end

function Application:removeMonitor( side )
	functionParameters.check( 1, "side", "string", side )

	for i = #self.terminals, 1, -1 do
		if self.terminals[i] == self.monitor_sides[side] then
			table.remove( self.terminals, i )
			self.monitor_sides[side] = nil
			break
		end
	end
	return self
end

function Application:positionChildrenInColumn( padding, order )
	padding = padding or 0
	order = order or "ascending"

	functionParameters.check( 2, "padding", "number", padding, "order", "string", order )
	if order ~= "ascending" and order ~= "descending" then throw( IncorrectParameterException( "invalid order '" .. order .. "', expected 'ascending' or 'descending'" ) ) end

	local children = self.children
	local y = 0

	for i = order == "ascending" and 1 or #children, order == "ascending" and #children or 1, order == "ascending" and 1 or -1 do
		children[i].y = y
		y = y + children[i].height + padding
	end

	self:setChanged()
end

function Application:positionChildrenInRow( padding, order )
	padding = padding or 0
	order = order or "ascending"

	functionParameters.check( 2, "padding", "number", padding, "order", "string", order )
	if order ~= "ascending" and order ~= "descending" then throw( IncorrectParameterException( "invalid order '" .. order .. "', expected 'ascending' or 'descending'" ) ) end

	local children = self.children
	local x = 0

	for i = order == "ascending" and 1 or #children, order == "ascending" and #children or 1, order == "ascending" and 1 or -1 do
		children[i].x = x
		x = x + children[i].width + padding
	end

	self:setChanged()
end

function Application:positionChildrenInGrid( hPadding, vPadding, order )
	return error( "positionChildrenInGrid() not yet supported" )
end

function Application:event( event, ... )
	local params = { ... }
	local children = {}

	local function handle( e )
		if e:typeOf( MouseEvent ) then
			for i = #children, 1, -1 do
				children[i]:handle( e:clone( children[i].x - self.viewportX, children[i].y - self.viewportY, true ) )
			end
		else
			for i = #children, 1, -1 do
				children[i]:handle( e )
			end
		end
	end

	if event == "timer" and timer.update( ... ) then
		return
	end
	for i = 1, #self.children do
		children[i] = self.children[i]
	end

	if event == "mouse_click" then
		self.mouse = {
			x = params[2] - 1, y = params[3] - 1;
			down = true, button = params[1];
			timer = os.startTimer( 1 ), time = os.clock(), moved = false;
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

	elseif event == "monitor_touch" and self.monitor_sides[params[1]] then
		handle( MouseEvent( SHEETS_EVENT_MOUSE_CLICK, params[2] - 1, params[3] - 1, 1 ) )

	elseif event == "chatbox_something" then
		-- handle( TextEvent( SHEETS_EVENT_VOICE, params[1] ) )

	elseif event == "char" then
		handle( TextEvent( SHEETS_EVENT_TEXT, params[1] ) )

	elseif event == "paste" then
		if self.keys.leftShift or self.keys.rightShift then
			handle( KeyboardEvent( SHEETS_EVENT_KEY_DOWN, keys.v, { leftCtrl = true, rightCtrl = true } ) )
		else
			handle( TextEvent( SHEETS_EVENT_PASTE, params[1] ) )
		end

	elseif event == "key" then
		handle( KeyboardEvent( SHEETS_EVENT_KEY_DOWN, params[1], self.keys ) )
		self.keys[keys.getName( params[1] ) or params[1]] = os.clock()

	elseif event == "key_up" then
		handle( KeyboardEvent( SHEETS_EVENT_KEY_UP, params[1], self.keys ) )
		self.keys[keys.getName( params[1] ) or params[1]] = nil

	elseif event == "term_resize" then
		self.width, self.height = term.getSize()
		for i = 1, #self.children do
			self.children[i]:onParentResized()
		end

	elseif event == "timer" and params[1] == self.mouse.timer then
		handle( MouseEvent( SHEETS_EVENT_MOUSE_HOLD, self.mouse.x, self.mouse.y, self.mouse.button, true ) )

	else
		handle( MiscEvent( event, ... ) )
	end
end

function Application:update()

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
end

function Application:draw()
	if self.changed then

		local screen = self.screen
		local children = {}
		local cx, cy, cc

		screen:clear()

		for i = 1, #self.children do
			children[i] = self.children[i]
		end

		for i = 1, #children do
			local child = children[i]

			if child:isVisible() then
				child:draw()
				child.canvas:drawTo( screen, child.x - self.viewportX, child.y - self.viewportY )
			
				if child.cursor_active then
					cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour
				end
			end
		end

		screen:drawToTerminals( self.terminals )

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

function Application:run()
	try (function()
		if self.load then
			self:load()
		end
		local t = timer.new( 0 )
		while self.running do
			local event = { coroutine.yield() }
			if event[1] == "timer" and event[2] == t then
				t = timer.new( .05 )
			elseif event[1] == "terminate" and self.terminateable then
				self:stop()
			else
				self:event( unpack( event ) )
			end
			self:update()
			self:draw()
		end
	end) {
		default (exceptionHandler);
	}
end

function Application:setChanged( state )
	self.changed = state ~= false
	return self
end

function Application:addChild( child )
	local children = self.children

	functionParameters.check( 1, "child", View, child )

	child.parent = self
	self:setChanged()

	for i = 1, #children do
		if children[i].z > child.z then
			table.insert( children, i, child )
			return child
		end
	end

	children[#children + 1] = child
	return child
end

function Application:isChildVisible( child )
	functionParameters.check( 1, "child", View, child )
	
	return child.x - self.viewportX + child.width > 0 and child.y - self.viewportY + child.height > 0 and child.x - self.viewportX < self.width and child.y - self.viewportY < self.height
end

application = Application()
Application = nil
