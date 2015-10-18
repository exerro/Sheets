
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.animation.Pause'
 -- @endif

 -- @print Including sheets.animation.Pause

class "Pause" {
	duration = 0;
	clock = 0;
	onFinish = nil;
}

function Pause:Pause( pause )
	self.duration = pause
end

function Pause:update( dt )
	self.clock = math.min( math.max( self.clock + dt, 0 ), self.duration )

	if self.clock == self.duration and type( self.onFinish ) == "function" then
		self:onFinish()
	end
end

function Pause:finished()
	return self.clock == self.duration
end
