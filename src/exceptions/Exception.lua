
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.exceptions.Exception'
 -- @endif

 -- @print Including sheets.exceptions.Exception

 -- @define SHEETS_EXCEPTION_ERROR "SHEETS_EXCEPTION\nPut code in a try block to catch the exception."

local exceptions = {}
local thrown

local function handler( t )
	for i = 1, #t do
		if t[i].catch == thrown.name or t[i].default or t[i].catch == thrown.class then
			return t[i].handler( thrown )
		end
	end
	return Exception.throw( thrown )
end

class "Exception" {
	name = "undefined";
	data = "undefined";
	trace = {};
	ID = 0;
}

function Exception:Exception( name, data, level )
	self.name = name
	self.data = data
	self.trace = {}

	level = ( level or 1 ) + 2

	for i = 1, 5 do
		local src = select( 2, pcall( error, "", level + i ) ):gsub( ": $", "" )

		if src == "pcall" then
			break
		else
			self.trace[i] = src
		end
	end
end

function Exception:getTraceback( initial, format )
	initial = initial or ""
	format = format or "\n"
	return initial .. table.concat( self.trace, format )
end

function Exception:getDataAndTraceback( indent )
	if type( self.data ) == "string" or class.isClass( self.data ) or class.isInstance( self.data ) then
		return tostring( self.data ) .. "\n" .. self:getTraceback( (" "):rep( indent or 1 ) .. "in ", "\n" .. (" "):rep( indent or 1 ) .. "in " )
	else
		return textutils.serialize( self.data ) .. "\n" .. self:getTraceback( (" "):rep( indent or 1 ) .. "in ", "\n" .. (" "):rep( indent or 1 ) .. "in " )
	end
end

function Exception:tostring()
	return tostring( self.name ) .. " exception:\n  " .. self:getDataAndTraceback( 4 )
end

function Exception.getExceptionById( ID )
	return exceptions[ID]
end

function Exception.throw( e, data, level )
	if class.isClass( e ) then
		e = e( data, ( level or 1 ) + 1 )
	elseif type( e ) == "string" then
		e = Exception( e, data, ( level or 1 ) + 1 )
	elseif not class.typeOf( e, Exception ) then
		return Exception.throw( "IncorrectParameterException", "expected class, string, or Exception e, got " .. class.type( e ) )
	end
	thrown = e
	error( SHEETS_EXCEPTION_ERROR, 0 )
end

function Exception.try( func )
	local ok, err = pcall( func )

	if not ok and err == SHEETS_EXCEPTION_ERROR then
		return handler
	end

	return error( err, 0 )
end

function Exception.catch( etype )
	return function( handler )
		return { catch = etype, handler = handler }
	end
end

function Exception.default( handler )
	return { default = true, handler = handler }
end
