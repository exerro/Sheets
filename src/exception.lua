
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exception.Exception'
 -- @endif

 -- @print Including sheets.exception.Exception

local ID = 0
local exceptions = {}
local thrownExceptionID

local function __tostring( e )
	local trace = ""
	for i = 1, #e.trace do
		trace = trace .. "\n in " .. e.trace[i]
	end
	return textutils.serialize( e.data ) .. trace
end

local function handler( t )
	local exception = exceptions[thrownExceptionID]
	for i = 1, #t do
		if t[i].catch == exception.name or t[i].default then
			return t[i].handler( exception )
		end
	end
end

local function exception( name, data, call_level )
	if type( name ) ~= "string" then return error( "expected string name, got " .. class.type( name ) ) end

	local function f( data, call_level )
		local e = setmetatable( { name = name, ID = ID }, { __tostring = __tostring } )
		local level = ( call_level or 1 ) + 1
		local trace = {}

		for i = 1, 5 do
			local src = select( 2, pcall( error, "", i + level ) )
			if src == "pcall: " then
				break
			else
				trace[i] = src:gsub( ":%s$", "", 1 )
			end
		end

		e.data = data
		e.trace = trace
		exceptions[ID] = e
		ID = ID + 1

		return e
	end

	if data == nil and call_level == nil then
		return f
	else
		return f( data, call_level )
	end
end

function throw( exception, data )
	if type( exception ) == "string" then
		if not data then
			return function( data )
				return throw( exception, data, 2 )
			end
		end
		exception = Exception( exception, data, 2 )
	end
	return error( "SheetsException-" .. exception.ID, 0 )
end

function try( func )
	local ok, err = pcall( func )

	if not ok and type( err ) == "string" then
		local ID = err:match "SheetsException%-(%d+)"
		if ID then
			thrownExceptionID = tonumber( ID )
			return handler
		end
	end

	return error( err, 0 )
end

function catch( etype )
	return function( handler )
		return { catch = etype, handler = handler }
	end
end

function default( handler )
	return { default = true, handler = handler }
end

IncorrectParameterException = exception "IncorrectParameterException"
IncorrectConstructorException = exception "IncorrectConstructorException"
