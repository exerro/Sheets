
 -- @once
 -- @print Including sheets.interfaces.ITagged

interface "ITagged" {
	tags = {};
	id = "ID";
}

function ITagged:ITagged()
	self.tags = {}
end

function ITagged:add_tag( tag )
	self.tags[tag] = true

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self
end

function ITagged:remove_tag( tag )
	self.tags[tag] = nil

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self
end

function ITagged:has_tag( tag )
	return self.tags[tag] or false
end

function ITagged:toggle_tag( tag )
	self.tags[tag] = not self.tags[tag] or nil

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self
end

function ITagged:set_ID( id ) -- TODO: make this a dynamic property
	self.id = tostring( id )

	if self.parent then
		self.parent:child_value_changed( self )
	end

	return self
end
