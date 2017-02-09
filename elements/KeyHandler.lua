
 -- @once
 -- @print Including sheets.elements.KeyHandler

class "KeyHandler" extends "Sheet"
{
	actions = {};
	shortcuts = {};
	handles_keyboard = true;
}

function KeyHandler:KeyHandler()
	self.actions = {}
	self.shortcuts = {}
	self:initialise()
	return self:Sheet( 0, 0, 0, 0 )
end

function KeyHandler:add_action( name, callback )
	for i = 1, #self.actions do
		if self.actions[i].name == name then
			Exception.throw( Exception, "cannot create new action '" .. name .. "': action already exists" )
		end
	end

	self.actions[#self.actions + 1] = {
		name = name;
		callback = callback;
		parameters = {};
		keybindings = {};
	}
end

function KeyHandler:remove_action( name )
	for i = 1, #self.actions do
		if self.actions[i].name == name then
			return table.remove( self.actions, i ).callback
		end
	end
end

function KeyHandler:set_callback( action, callback )
	for i = 1, #self.actions do
		if self.actions[i].name == action then
			self.actions[i].callback = callback
			return
		end
	end
end

function KeyHandler:set_parameters( action, parameters )
	for i = 1, #self.actions do
		if self.actions[i].name == action then
			self.actions[i].parameters = parameters
			return
		end
	end
end

function KeyHandler:bind_key( key, action )
	if self.shortcuts[key] then
		self:unbind_key( key )
	end

	for i = 1, #self.actions do
		if self.actions[i].name == action then
			self.actions[i].keybindings[#self.actions[i].keybindings + 1] = key
			self.shortcuts[key] = action
			return
		end
	end

	Exception.throw( Exception, "cannot bind key '" .. key .. "' to action '" .. action .. "': action doesn't exist" )
end

function KeyHandler:unbind_key( key )
	local action = self.shortcuts[key]

	if not action then
		Exception.throw( Exception, "cannot unbind key '" .. key ..  "': key not bound" )
	end

	for i = 1, #self.actions do
		if self.actions[i].name == action then
			for j = 1, #self.actions[i].keybindings do
				if self.actions[i].keybindings[j] == key then
					table.remove( self.actions[i].keybindings, j )
					break
				end
			end

			self.shortcuts[key] = nil
			return
		end
	end
end

function KeyHandler:on_keyboard_event( event )
	if not event.handled and event:is( SHEETS_EVENT_KEY_DOWN ) then
		local longest_match, longest_match_action
		local actions = self.actions
		local shortcuts = self.shortcuts
		local k, v = next( shortcuts )

		while k do
			if event:matches( k ) then
				if not longest_match or #k > #longest_match then
					longest_match = k
					longest_match_action = v
				end
			end

			k, v = next( shortcuts, k )
		end

		if longest_match then
			event:handle( self )

			for i = 1, #actions do
				if actions[i].name == longest_match_action then
					return actions[i].callback( self )
				end
			end
		end
	end
end

function KeyHandler:draw() end
