
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.KeyHandler'
 -- @endif

 -- @print Including sheets.KeyHandler

class "KeyHandler" extends "Sheet"
{
	shortcuts = {};
	handlesKeyboard = true;
}

function KeyHandler:KeyHandler()
	self.shortcuts = {}
	return self:Sheet( 0, 0, 0, 0 )
end

function KeyHandler:addShortcut( shortcut, handler )
	functionParameters.check( 2,
		"shortcut", "string", shortcut,
		"handler", "function", handler
	)
	self.shortcuts[shortcut] = handler
end

function KeyHandler:removeShortcut( shortcut )
	functionParameters.check( 1,
		"shortcut", "string", shortcut
	)
	self.shortcuts[shortcut] = nil
end

function KeyHandler:onKeyboardEvent( event )
	if not event.handled and event:is( SHEETS_EVENT_KEY_DOWN ) then
		local shortcuts = self.shortcuts
		local k, v = next( shortcuts )

		while k do

			if event:matches( k ) then
				event:handle()
				v( self )
				return
			end

			k, v = next( shortcuts, k )
		end
	end
end

function KeyHandler:draw() end
