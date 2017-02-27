
 -- @include exceptions.Exception
 -- @include exceptions.LoggerException

 -- @print including(core.Logger)

local active = {}

@class Logger {
	path = "";
}

function Logger:Logger( path )
	parameters.check_constructor( self.class, 1, "path", "string", path )
	self.path = path

	local h = io.open( path, "w" )

	if h then
		h:close()
	else
		Exception.throw( LoggerException.file_open_failed( path ) )
	end

	active[#active + 1] = self
end

function Logger:write( data )
	parameters.check( 1, "data", "string", data )

	local logs = self == Logger and active or { self }
	local time = os.clock()
	local timefmt = "[" .. tostring( time ) .. (time % 1 == 0 and ".00" or time % 0.1 == 0 and "0" or "") .. "] "

	for i = 1, #logs do
		local h = io.open( logs[i].path, "a" )

		if h then
			h:write( timefmt .. data .. "\n" )
			h:close()
		else
			Exception.throw( LoggerException.file_open_failed( logs[i].path ) )
		end
	end
end

function Logger:log( data )
	return self:write( "INFO :: " .. tostring( data ) )
end

function Logger:note( data, userspace )
	local trace = Exception.traceback( 2, 1, userspace )
	return self:write( "NOTICE :: " .. tostring( data ) .. "\n\tin " .. table.concat( trace, "\n\tin " ) )
end

function Logger:warn( data, userspace )
	local trace = Exception.traceback( 2, 3, userspace )
	return self:write( "WARNING :: " .. tostring( data ) .. "\n\tin " .. table.concat( trace, "\n\tin " ) )
end

function Logger:error( exception )
	parameters.check( 1, "exception", Exception, exception )
	self:write( "FATAL :: " .. exception:tostring() )
	return Exception.throw( exception )
end

function Logger:close()
	if self == Logger then
		active = {}
	else
		for i = 1, #active do
			if active[i] == self then
				return table.remove( active, i )
			end
		end
	end
end
