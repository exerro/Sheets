
local state = ...
local module = {}
local minify = {}
local header = "local __f,__err=load("
local h = fs.open( "sheets/lib/minify.lua", "r" )

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

		if self.env.SHEETS_MINIFY then
			self:write( minify.Rebuild.MinifyString( self:build() ) )
		else
			self:write( self:build() )
		end
	end
end

local function requirefile( self, file, name, lib )
	if not self.included[file] then
		local h = fs.open( file, "r" )
		local content = h.readAll()
		local str

		h.close()

		self:push( content )
		self.active_include = file

		if self.env.SHEETS_MINIFY then
			str = header .. ("%q"):format( minify.Rebuild.MinifyString( self:build() ) ) .. "," .. ("%q"):format( name ) .. ",nil,_ENV)if not __f then error(__err,0)end"
		else
			str = header .. ("%q"):format( self:build() ) .. "," .. ("%q"):format( name ) .. ",nil,_ENV)if not __f then error(__err,0)end"
		end

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

state.included = {}

function module:include_raw( file )
	if file:sub( 1, 1 ) == "/" then
		if isFile( file .. ".lua" ) then
			return includefile( self, file .. ".lua" )
		else
			return error( "Cannot find file '" .. file .. "'", 0 )
		end
	end

	for i = 1, #self.include_paths do
		if isFile( self.include_paths[i] .. "/" .. file .. ".lua" ) then
			return includefile( self, self.include_paths[i] .. "/" .. file .. ".lua" )
		elseif isFile( self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua" ) then
			return includefile( self, self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua" )
		elseif isFile( self.include_paths[i] .. "/" .. file ) then
			return includefile( self, self.include_paths[i] .. "/" .. file )
		end
	end
	return error( "Cannot find file '" .. file .. "'", 0 )
end

function module:require_raw( file )
	local lib
	if file:find "^.-%sas%s[%w_]+$" then
		file, lib = file:match "^(.-)%sas%s([%w_]+)$"
	end

	if file:sub( 1, 1 ) == "/" then
		if isFile( file .. ".lua" ) then
			return requirefile( self, file .. ".lua", lib or file, lib ~= nil )
		else
			return error( "Cannot find file '" .. file .. "'", 0 )
		end
	end

	for i = 1, #self.include_paths do
		if isFile( self.include_paths[i] .. "/" .. file .. ".lua" ) then
			return requirefile( self, self.include_paths[i] .. "/" .. file .. ".lua", lib or file, lib ~= nil )
		elseif isFile( self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua" ) then
			return requirefile( self, self.include_paths[i] .. "/" .. file .. "/" .. fs.getName( file ) .. ".lua", lib or file, lib ~= nil )
		elseif isFile( self.include_paths[i] .. "/" .. file ) then
			return requirefile( self, self.include_paths[i] .. "/" .. file, lib or file, lib ~= nil )
		end
	end
	return error( "Cannot find file '" .. file .. "'", 0 )
end

function module:include( data )
	return module.include_raw( self, data:gsub( "%.", "/" ) )
end

function module:require( data )
	return module.require_raw( self, data:gsub( "%.", "/" ) )
end

function module:once()
	self:write ""
	self.included[self.active_include] = true
end

return module
