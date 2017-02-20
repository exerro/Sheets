
 -- @print including(interfaces.ITagged)

@interface ITagged {
	tags = {};
	subscriptions = {};
	id = "ID";
}

function ITagged:ITagged()
	self.tags = {}
	self.subscriptions = {}
end

function ITagged:add_tag( tag )
	self.tags[tag] = true

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self:trigger( tag )
end

function ITagged:remove_tag( tag )
	self.tags[tag] = ni

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self:trigger( tag )
end

function ITagged:has_tag( tag )
	return self.tags[tag] or false
end

function ITagged:toggle_tag( tag )
	self.tags[tag] = not self.tags[tag] or nil

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self:trigger( tag )
end

function ITagged:set_ID( id ) -- TODO: make this a dynamic property
	self.id = tostring( id )

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self
end

function ITagged:subscribe_to_tag( tag, lifetime, callback )
	self.subscriptions[tag] = self.subscriptions[tag] or {}
	self.subscriptions[tag][#self.subscriptions[tag] + 1] = callback
	lifetime[#lifetime + 1] = { "tag", self, tag, callback }

	return callback
end

function ITagged:unsubscribe_from_tag( tag, f )
	if self.subscriptions[tag] then
		for i = #self.subscriptions[tag], 1, -1 do
			if self.subscriptions[tag][i] == f then
				return table.remove( self.subscriptions[tag], i )
			end
		end
	end
end

function ITagged:trigger( tag )
	if self.subscriptions[tag] then
		for i = #self.subscriptions[tag], 1, -1 do
			self.subscriptions[tag][i]()
		end
	end

	return self
end
