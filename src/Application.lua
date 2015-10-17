
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Application'
 -- @endif

 -- @print Including sheets.Application

class "Application"
{
	name = "UnNamed Application";

	width = 0;
	height = 0;

	root = nil;

	running = true;
}

Application.active = nil

function Application:Application( name )
	-- @if SHEETS_TYPE_CHECK

	-- @endif

	self.name = name
	self.width, self.height = term.getSize()

	self.root = Sheet( 0, 0, self.width, self.height )
end

function Application:update( event, ... )
	Application.active = self

	if event == "timer" and timer.update( ... ) then
		Application.active = nil
		return
	end

	if event == "mouse_click" then

	elseif event == "mouse_up" then

	elseif event == "mouse_drag" then

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

function Application:draw()

end

function Application:run()
	while self.running do
		self:update( coroutine.yield() )
		self:draw()
	end
end
