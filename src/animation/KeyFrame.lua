
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.animation.KeyFrame'
 -- @endif

 -- @print Including sheets.animation.KeyFrame

class "KeyFrame" {
	clock = 0;
	value = 0;
	initial = 0;
	difference = 0;
	duration = 0;
	easing = nil;
	onFinish = nil;
}

function KeyFrame:KeyFrame( initial, final, duration, easing )
	self.duration = duration
	self.initial = initial
	self.difference = final - initial
	self.easing = easing
	self.value = initial
end

function KeyFrame:update( dt )
	self.clock = math.min( math.max( self.clock + dt, 0 ), self.duration )

	self.value = self.easing( self.initial, self.difference, self.clock / self.duration )
end

function KeyFrame:finished()
	return self.clock == self.duration
end
