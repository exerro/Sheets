
 -- @include Exception

 -- @print including(exceptions.DynamicCastException)
 -- @print including(exceptions.DynamicCastException)

@private
@class DynamicCastException extends Exception {

}

function DynamicCastException:DynamicCastException( type, expected, position )
	local lines = {}

	Logger:warn "here"

	for i = 1, #position.lines do
		lines[i] = ("%q"):format( position.lines[i] )
	end

	return self:Exception( self:type(), "cast failure in '" .. position.source .. "' (expected " .. expected:tostring() .. ", got " .. type:tostring() .. ")\n" .. table.concat( lines, "\n" ), 1, true )
end
