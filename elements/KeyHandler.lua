
 -- @once
 -- @print Including sheets.elements.KeyHandler

class "KeyHandler" extends "Sheet"
{
	shortcuts = {};
	handles_keyboard = true;
}

function KeyHandler:KeyHandler()
	self.shortcuts = {}
	return self:Sheet( 0, 0, 0, 0 )
end

function KeyHandler:add_shortcut( shortcut, handler )
	parameters.check( 2,
		"shortcut", "string", shortcut,
		"handler", "function", handler
	)
	self.shortcuts[shortcut] = handler
end

function KeyHandler:remove_shortcut( shortcut )
	parameters.check( 1,
		"shortcut", "string", shortcut
	)
	self.shortcuts[shortcut] = nil
end

function KeyHandler:on_keyboard_event( event )
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
