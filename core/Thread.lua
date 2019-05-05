
 -- @print including(core.Thread)

@class Thread {
	running = true;

	f = nil;
	co = nil;
	filter = nil;
}

function Thread:Thread( f, ... )
	if type( f ) == "string" then
		f = load( f )
	elseif type( f ) ~= "function" then
		parameters.check( 1, "f", "function/string", f )
	end

	self.f = f
	self.co = coroutine.create( f )

	return self:resume( ... )
end

function Thread:stop()
	self.running = false
end

function Thread:restart()
	self.running = true
	self.co = coroutine.create( self.f )
end

function Thread:resume( event, ... )
	if not self.running or (self.filter ~= nil and event ~= self.filter) then
		return
	end

	local ok, data = coroutine.resume( self.co, event, ... )

	if ok then
		if coroutine.status( self.co ) == "dead" then
			self.running = false
		end

		self.filter = data
	else
		if data == EXCEPTION_ERROR then
			data = Exception.thrown()
		end

		return Exception.throw( ThreadRuntimeException( self, data, 0 ) )
	end
end
