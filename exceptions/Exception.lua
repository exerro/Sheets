
 -- @print including(exceptions.Exception)

local thrown

local function handler( t )
	for i = 1, #t do
		if t[i].catch == thrown.name or t[i].default or t[i].catch == thrown.class then
			return t[i].handler( thrown )
		end
	end
	return Exception.throw( thrown )
end

@class Exception {
	name = "undefined";
	data = "undefined";
	trace = {};
}

function Exception:Exception( name, data, level, userspace )
	self.name = name
	self.data = data
	self.trace = {}

	level = ( level or 1 ) + 2

	if level > 2 then
		local i = 1

		while #self.trace < 5 do
			local src = select( 2, pcall( error, "", level + i ) ):gsub( ": $", "" )

			if src == "pcall" or src == "" then
				break
			else
				local src_and_line

				if __get_src_and_line then
					local line, msg = src:match( "^" .. (select(2,pcall(error,"@",2)):match"^(.*):%d+: @$") .. ":(%d+)$" )

					if line then
						src, line = __get_src_and_line( tonumber( line ) )
						src_and_line = src .. "[" .. line .. "]"
					else
						src_and_line = ("%s[%s]"):format( src:match "(.+):(%d+)" )
					end
				else
					src_and_line = ("%s[%s]"):format( src:match "(.+):(%d+)" )
				end

				if not (userspace and src:find "^sheets%.") then
					print( src )
					userspace = false
					self.trace[#self.trace + 1] = src_and_line
				end
			end
			i = i + 1
		end
	end
end

function Exception:get_traceback( initial, delimiter )
	initial = initial or ""
	delimiter = delimiter or "\n"

	parameters.check( 2, "initial", "string", initial, "delimiter", "string", delimiter )

	if #self.trace == 0 then return "" end

	return initial .. table.concat( self.trace, delimiter )
end

function Exception:get_data()
	if type( self.data ) == "string" or class.is_class( self.data ) or class.is_instance( self.data ) then
		return tostring( self.data )
	else
		return textutils.serialize( self.data )
	end
end

function Exception:get_data_and_traceback( indent )
	parameters.check( 1, "indent", "number", indent or 1 )
	indent = math.max( indent or 1, 1 )

	return (" "):rep( indent * 4 - 2 ) .. self:get_data():gsub( "\n", "\n" .. (" "):rep( indent * 4 - 2 ) )
	    .. self:get_traceback( "\n" .. (" "):rep( indent * 4 ) .. "in ", "\n" .. (" "):rep( indent * 4 ) .. "in " )
end

function Exception:tostring()
	return tostring( self.name ) .. ":\n" .. self:get_data_and_traceback( 1 )
end

function Exception.thrown()
	return thrown
end

function Exception.throw( e, data, level )
	if class.is_class( e ) then
		e = e( data, ( level or 1 ) + 1 )
	elseif type( e ) == "string" then
		e = Exception( e, data, ( level or 1 ) + 1 )
	elseif not class.type_of( e, Exception ) then
		return Exception.throw( "IncorrectParameterException", "expected class, string, or Exception e, got " .. class.type( e ) )
	end
	thrown = e
	error( EXCEPTION_ERROR, 0 )
end

function Exception.try( func )
	local ok, err = pcall( func )

	if not ok and err == EXCEPTION_ERROR then
		return handler
	end

	return not ok and error( err, 0 ) or function() end
end

function Exception.catch( etype )
	return function( handler )
		return { catch = etype, handler = handler }
	end
end

function Exception.default( handler )
	return { default = true, handler = handler }
end
