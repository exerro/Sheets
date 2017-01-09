
 -- @once
 -- @print Including sheets.core.Application

local function exception_handler( e )
	return error( tostring( e ), 0 )
end

local handle_event

class "Application"
{
	name = "UnNamed Application";
	path = "";

	terminateable = true;
	running = true;

	screens = {};
	screen = nil;

	resource_loaders = {};
	extensions = {};

	threads = {};

	mouse = nil;
	keys = {};
	changed = false;
}

function Application:Application( name, path )
	self.screens = { Screen( self, term.getSize() ):add_terminal( term ) }
	self.screen = self.screens[1]

	self.name = name
	self.path = path or name

	self.resource_loaders = {}
	self.extensions = {}
	self.threads = {}
	self.keys = {}
end

function Application:register_resource_loader( type, loader )
	parameters.check( 2, "type", "string", type, "loader", "function", loader )

	self.resource_loaders[type] = loader
end

function Application:unregister_resource_loader( type )
	parameters.check( 1, "type", "string", type )
	self.resource_loaders[type] = nil
end

function Application:register_file_extension( extension, type )
	parameters.check( 2, "extension", "string", extension, "type", "string", type )

	self.extensions[extension] = type
end

function Application:unregister_file_extension( extension )
	parameters.check( 1, "extension", "string", extension )

	self.extensions[extension] = nil
end

function Application:load_resource( resource, type, ... )
	parameters.check( 2, "resource", "string", resource, "type", "string", type or "" )

	if not type then
		type = self.extensions[resource:match( "%.(%w+)$" ) or "txt"] or "text.plain"
	end

	if self.resource_loaders[type] then

		local h = fs.open( fs.combine( self.path, resource ), "r" ) or fs.open( resource, "r" )
		if h then

			local content = h.readAll()
			h.close()

			return self.resource_loaders[type]( self, resource, content, ... )

		else
			Exception.throw( ResourceLoadException, "Failed to open file '" .. resource .. "': not found under '/'' or '" .. self.path .. "'", 2 )
		end

	else
		Exception.throw( ResourceLoadException, "No loader for resource type '" .. type .. "'", 2 )
	end
end

function Application:add_thread( thread )
	parameters.check( 1, "thread", Thread, thread )

	self.threads[#self.threads + 1] = thread

	return thread
end

function Application:is_key_pressed( key )
	parameters.check( 1, "key", "string", key )

	self.resource_loaders = {}
	self.extensions = {}

	return self.keys[key] ~= nil
end

function Application:stop()
	self.running = false
	return self
end

function Application:add_screen()

	local screen = Screen( self, term.get_size() )
	self.screens[#self.screens + 1] = screen
	return screen

end

function Application:remove_screen( screen )

	parameters.check( 1, "screen", Screen, screen )

	for i = #self.screens, 1, -1 do
		if self.screens[i] == screen then
			return table.remove( self.screens, i )
		end
	end

end

function Application:query( query )
	local query_f = query_utils.get_function( query )
	local nodes = {}
	local matches = {}

	for i = 1, #self.screens do
		local c = self.screens[i]:get_children()

		for n = 1, #c do
			nodes[#nodes + 1] = c[n]
		end
	end

	while nodes[1] do
		local node = table.remove( nodes, 1 )

		if query_f( node ) then
			matches[#matches + 1] = node
		end

		if node.get_children then
			local c = node:get_children()

			for i = 1, #c do
				table.insert( nodes, i, c[i] )
			end
		end
	end

	return matches
end

function Application:event( event, ... )
	local params = { ... }

	if event == "timer" and timer.update( ... ) then
		return
	end

	return handle_event( self, event, params, ... )
end

function Application:draw()

	if self.changed then
		for i = 1, #self.screens do
			self.screens[i]:draw()
		end
		self.changed = false
	end

end

function Application:update()

	local dt = timer.get_delta()
	timer.step()

	for i = 1, #self.screens do
		self.screens[i]:update( dt )
	end

	if self.on_update then
		self:on_update( dt )
	end

end

function Application:load()
	self.changed = true

	if self.on_load then
		return self:on_load()
	end
end

function Application:run()

	Exception.try (function()
		self:load()
		local t = timer.new( 0 ) -- updating timer
		while self.running do
			local event = { coroutine.yield() }
			if event[1] == "timer" and event[2] == t then
				t = timer.new( .05 )
				timer.update( event[2] )
			elseif event[1] == "terminate" and self.terminateable then
				self:stop()
			else
				self:event( unpack( event ) )
			end
			self:update()
			self:draw()
		end

	end) {
		Exception.default (exception_handler);
	}

end

function handle_event( self, event, params, ... )
	local screens = {}

	for i = 1, #self.screens do
		screens[i] = self.screens[i]
	end

	if event == "mouse_click" then
		self.mouse = {
			x = params[2] - 1, y = params[3] - 1;
			down = true, button = params[1];
			timer = os.startTimer( 1 ), time = os.clock(), moved = false;
		}

		local e = MouseEvent( SHEETS_EVENT_MOUSE_DOWN, params[2] - 1, params[3] - 1, params[1], true )

		for i = #screens, 1, -1 do
			if screens[i]:gets_term_events() then
				screens[i]:handle( e )
			end
		end

	elseif event == "mouse_up" then
		local e = MouseEvent( SHEETS_EVENT_MOUSE_UP, params[2] - 1, params[3] - 1, params[1], true )

		for i = #screens, 1, -1 do
			if screens[i]:gets_term_events() then
				screens[i]:handle( e )
			end
		end

		self.mouse.down = false
		os.cancelTimer( self.mouse.timer )

		if not self.mouse.moved and os.clock() - self.mouse.time < 1 and params[1] == self.mouse.button then
			local e = MouseEvent( SHEETS_EVENT_MOUSE_CLICK, params[2] - 1, params[3] - 1, params[1], true )

			for i = #screens, 1, -1 do
				if screens[i]:gets_term_events() then
					screens[i]:handle( e )
				end
			end
		end

	elseif event == "mouse_drag" then
		local e = MouseEvent( SHEETS_EVENT_MOUSE_DRAG, params[2] - 1, params[3] - 1, params[1], true )

		for i = #screens, 1, -1 do
			if screens[i]:gets_term_events() then
				screens[i]:handle( e )
			end
		end

		self.mouse.moved = true
		os.cancelTimer( self.mouse.timer )

	elseif event == "mouse_scroll" then
		local e = MouseEvent( SHEETS_EVENT_MOUSE_SCROLL, params[2] - 1, params[3] - 1, params[1], true )

		for i = #screens, 1, -1 do
			if screens[i]:gets_term_events() then
				screens[i]:handle( e )
			end
		end

	elseif event == "monitor_touch" then
		local events = {
			MouseEvent( SHEETS_EVENT_MOUSE_DOWN, params[2] - 1, params[3] - 1, 1 );
			MouseEvent( SHEETS_EVENT_MOUSE_UP, params[2] - 1, params[3] - 1, 1 );
			MouseEvent( SHEETS_EVENT_MOUSE_CLICK, params[2] - 1, params[3] - 1, 1 );
		}

		for i = 1, #screens do
			if screens[i]:uses_monitor( params[1] ) then
				for n = 1, #events do
					screens[i]:handle( events[n] )
				end
			end
		end

	elseif event == "chatbox_something" then
		-- TODO: implement this
		-- handle( TextEvent( SHEETS_EVENT_VOICE, params[1] ) )

	elseif event == "char" then
		local e = TextEvent( SHEETS_EVENT_TEXT, params[1] )

		for i = #screens, 1, -1 do
			screens[i]:handle( e )
		end

	elseif event == "paste" then
		local e
		if self.keys.leftShift or self.keys.rightShift then -- TODO: why the left_ctrl/right_ctrl?
			e = KeyboardEvent( SHEETS_EVENT_KEY_DOWN, keys.v, { left_ctrl = true, right_ctrl = true } )
		else
			e = TextEvent( SHEETS_EVENT_PASTE, params[1] )
		end

		for i = #screens, 1, -1 do
			screens[i]:handle( e )
		end

	elseif event == "key" then
		self.keys[keys.getName( params[1] ) or params[1]] = os.clock()
		local e = KeyboardEvent( SHEETS_EVENT_KEY_DOWN, params[1], self.keys )

		for i = #screens, 1, -1 do
			screens[i]:handle( e )
		end

	elseif event == "key_up" then
		self.keys[keys.getName( params[1] ) or params[1]] = nil
		local e = KeyboardEvent( SHEETS_EVENT_KEY_UP, params[1], self.keys )

		for i = #screens, 1, -1 do
			screens[i]:handle( e )
		end

	elseif event == "term_resize" then
		local width, height = term.getSize()

		for i = 1, #screens do
			if screens[i].terminals[1] == term then
				screens[i]:set_width( width )
				screens[i]:set_height( height )
			end
		end

	elseif event == "timer" and self.mouse and params[1] == self.mouse.timer then
		local e = MouseEvent( SHEETS_EVENT_MOUSE_HOLD, self.mouse.x, self.mouse.y, self.mouse.button, true )

		for i = #screens, 1, -1 do
			if screens[i]:gets_term_events() then
				screens[i]:handle( e )
			end
		end

	else
		local ev = MiscEvent( event, ... )
		handle( ev )

		if not ev.handled then
			for i = #self.threads, 1, -1 do
				if self.threads[i].running then
					self.threads[i]:resume( event, ... )
				else
					table.remove( self.threads, i )
				end
			end
		end
	end
end
