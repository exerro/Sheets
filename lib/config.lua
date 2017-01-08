
local config_methods = {}

local serialize = textutils.serialize
local unserialize = textutils.unserialize

local function open_config( path )
	local config = setmetatable( { path = path, data = {}, autosaving = false, changed = false }, { __index = config_methods } )
	local h = io.open( path, "r" )

	if h then
		local content = h:read "*a"
		local data

		h:close()
		data = unserialize( content )

		if type( data ) ~= "table" then
			return nil, "corrupt config file"
		end

		config.data = data
	elseif not fs.exists( path ) then
		local h = io.open( path, "w" )

		if h then
			h:write "{}"
			h:close()
		else
			return nil, "failed to open config file"
		end
	end

	return config
end

function config_methods:read( index )
	local v = self.data

	for seg in index:gmatch "[^.]+" do
		if type( v ) ~= "table" then
			return nil
		end

		v = v[seg]
	end

	return v
end

function config_methods:exists( index )
	return self:read( index ) ~= nil
end

function config_methods:write( index, value )
	local v = self.data
	local segments = {}

	for seg in index:gmatch "[^.]+" do
		segments[#segments + 1] = seg
	end

	for i = 1, #segments - 1 do
		if type( v[segments[i]] ) ~= "table" then
			v[segments[i]] = {}
		end
		v = v[segments[i]]
	end

	v[segments[#segments]] = value
	self.changed = true

	if self.autosaving then
		self:save()
	end

	return self
end

function config_methods:clear( index )
	return self:write( index, nil )
end

function config_methods:autosave()
	self.autosaving = true

	if self.changed then
		self:save()
	end

	return self
end

function config_methods:save()
	if not self.changed then
		return true
	end

	local h = io.open( self.path, "w" )

	if h then
		h:write( serialize( self.data ) )
		h:close()

		return true
	end

	return false
end

function config_methods:close()
	if self:save() then
		setmetatable( self, {} )

		return true
	end

	return false
end

return { open = open_config }
