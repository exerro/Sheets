
 -- @print including(interfaces.ITimer)

local clockf = os.clock

if ccemux then
	local milliTime = ccemux.milliTime
	clockf = function()return milliTime()/1000 end
end

@private
@interface ITimer {
	timerID = 0;
	time = nil;
	lt = nil;
	timers = {};
}

function ITimer:ITimer()
	self.time = clockf()
	self.timers = {}
	self:step_timer()

	function self:ITimer() end
end

function ITimer:new_timer( n )
	parameters.check( 1, "n", "number", n )

	local finish, ID = self.time + n, nil -- avoids duplicating timer events
	for i = 1, #self.timers do
		if self.timers[i].time == finish then
			ID = self.timers[i].ID
			break
		end
	end
	return ID or os.startTimer( n )
end

function ITimer:queue( response, n )
	parameters.check( 2, "response", "function", response, "n", "number", n )

	local timer_id = self:new_timer( n )
	local finish = self.time + n
	self.timers[#self.timers + 1] = { time = finish, response = response, ID = timer_id }
	return timer_id
end

function ITimer:cancel_timer( ID )
	parameters.check( 1, "ID", "number", ID )

	for i = #self.timers, 1, -1 do
		if self.timers[i].ID == ID then
			table.remove( self.timers, i )
			break
		end
	end

	return self
end

function ITimer:step_timer()
	self.lt = self.time
	self.time = clockf()

	return self
end

function ITimer:get_timer_delta()
	return self.time - self.lt
end

function ITimer:update_timer( timer_id )
	local updated = false

	for i = #self.timers, 1, -1 do
		if self.timers[i].ID == timer_id then
			table.remove( self.timers, i ).response()
			updated = true
		end
	end

	return updated
end
