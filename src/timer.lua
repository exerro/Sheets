
timer = {}

local timers = {}
local timerID = 0
local t, lt = os.clock()

function timer.new( n )
	functionParameters.check( 1, "n", "number", n )

	local finish, ID = t + n, false -- avoids duplicating timer events
	for i = 1, #timers do
		if timers[i].time == finish then
			ID = timers[i].ID
			break
		end
	end
	return ID or os.startTimer( n )
end

function timer.queue( n, response )
	functionParameters.check( 2, "n", "number", n, "response", "function", response )

	local finish, ID = t + n, false -- avoids duplicating timer events
	for i = 1, #timers do
		if timers[i].time == finish then
			ID = timers[i].ID
			break
		end
	end

	local timerID = ID or os.startTimer( n )
	timers[#timers + 1] = { time = finish, response = response, ID = timerID }
	return timerID
end

function timer.cancel( ID )
	functionParameters.check( 1, "ID", "number", ID )

	for i = #timers, 1, -1 do
		if timers[i].ID == ID then
			return table.remove( timers, i ).time - t
		end
	end
	return 0
end

function timer.step()
	lt = t
	t = os.clock()
end

function timer.getDelta()
	return t - lt
end

function timer.update( timerID )
	local updated = false
	for i = #timers, 1, -1 do
		if timers[i].ID == timerID then
			table.remove( timers, i ).response()
			updated = true
		end
	end
	return updated
end

timer.step()
