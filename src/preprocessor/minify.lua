
local state = ...

local minify = {}
local h = fs.open( "sheets/preprocessor/minify_api.lua", "r" )
local header = "local __f,__err=load("

local function isFile( file )
	return fs.exists( file ) and not fs.isDir( file )
end

local function includefile( self, file )
	if not self.included[file] then
		local h = fs.open( file, "r" )
		local content = h.readAll()
		h.close()

		self:push( content )
		self.active_include = file
		self:write( minify.Rebuild.MinifyString( self:build() ) )
	end
end

local function requirefile( self, file, name, lib )
	if not self.included[file] then
		local h = fs.open( file, "r" )
		local content = h.readAll()
		h.close()

		self:push( content )
		self.active_include = file
		local str = header .. ("%q"):format( minify.Rebuild.MinifyString( self:build() ) ) .. "," .. ("%q"):format( name ) .. ",nil,_ENV)if not __f then error(__err,0)end"
		self:write( str .. ( lib and " local " .. name .. "=__f()" or " __f()" ) )
	end
end

if h then
	local content = h.readAll()
	h.close()

	local env = setmetatable( {}, { __index = _ENV or getfenv() } )

	local f, err = load( content, "minify", nil, env )
	if f then
		f()

		for k, v in pairs( env ) do
			minify[k] = v
		end
	else
		error( err, 0 )
	end
else
	return error( "Failed to open minify API", 0 )
end

local module = {}

function module:include( data )
	local file = data:gsub( "%.", "/" )
	for i = 1, #self.include_paths do
		if isFile( self.include_paths[i] .. "/" .. file .. ".lua" ) then
			return includefile( self, self.include_paths[i] .. "/" .. file .. ".lua" )
		elseif isFile( self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua" ) then
			return includefile( self, self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua" )
		elseif isFile( self.include_paths[i] .. "/" .. data ) then
			return includefile( self, self.include_paths[i] .. "/" .. data )
		end
	end
	return error( "Cannot find file '" .. data .. "'", 0 )
end

function module:require( data )
	local data, lib = data
	if data:find "^.-%sas%s[%w_]+$" then
		data, lib = data:match "^(.-)%sas%s([%w_]+)$"
	end
	local file = data:gsub( "%.", "/" )
	for i = 1, #self.include_paths do
		if isFile( self.include_paths[i] .. "/" .. file .. ".lua" ) then
			return requirefile( self, self.include_paths[i] .. "/" .. file .. ".lua", lib or data, lib ~= nil )
		elseif isFile( self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua" ) then
			return requirefile( self, self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua", lib or data, lib ~= nil )
		elseif isFile( self.include_paths[i] .. "/" .. data ) then
			return requirefile( self, self.include_paths[i] .. "/" .. data, lib or data, lib ~= nil )
		end
	end
	return error( "Cannot find file '" .. data .. "'", 0 )
end

return module
