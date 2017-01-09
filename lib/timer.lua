
 -- @once

timer = {}

local timers = {}
local timer_id = 0
local t, lt = os.clock()

function timer.new( n )
	parameters.check( 1, "n", "number", n )

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
	parameters.check( 2, "n", "number", n, "response", "function", response )

	local timer_id = timer.new( n )
	timers[#timers + 1] = { time = finish, response = response, ID = timer_id }
	return timer_id
end

function timer.cancel( ID )
	parameters.check( 1, "ID", "number", ID )

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

function timer.get_delta()
	return t - lt
end

function timer.update( timer_id )
	local updated = false
	for i = #timers, 1, -1 do
		if timers[i].ID == timer_id then
			table.remove( timers, i ).response()
			updated = true
		end
	end
	return updated
end

timer.step()
