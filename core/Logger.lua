
 -- @include exceptions.Exception
 -- @include exceptions.LoggerException

 -- @print including(core.Logger)

local active = {}

@class Logger {
	path = "";
}

function Logger:Logger( path )
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
	local logs = self == Logger and active or { self }
	--local time = ccemux and math.floor( ccemux.milliTime() / 10 + 0.5 ) / 100 or os.clock()
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

function Logger:warn( data, userspace )
	local trace = Exception.traceback( 2, 3, userspace )
	return self:write( "WARNING :: " .. tostring( data ) .. "\n\tin " .. table.concat( trace, "\n\tin " ) )
end

function Logger:error( exception )
	self:write( "FATAL :: " .. exception:tostring() )
	return Exception.throw( exception )
end
