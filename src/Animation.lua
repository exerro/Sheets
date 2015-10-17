
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.Animation'
 -- @endif

 -- @print Including sheets.Animation

class "Animation" {
	frames = {};
	value = 0;
	rounded = false;
}

function Animation:Animation( ... )
	local frames = { ... }
	-- do some type checking
	self.frames = frames
	self.value = frames[1] and frames[1].value
end

function Animation:setRounded( value )
	self.rounded = value ~= false
	return self
end

function Animation:addKeyFrame( initial, final, duration, easing )
	if easing == SHEETS_EASING_TRANSITION then
		easing = easing_transition
	elseif easing == SHEETS_EASING_EXIT then
		easing = easing_exit
	elseif easing == SHEETS_EASING_ENTRANCE then
		easing = easing_entrance
	end
	 -- @if SHEETS_TYPE_CHECK
		if type( initial ) ~= "number" then return error( "expected number initial, got " .. type( initial ) ) end
		if type( final ) ~= "number" then return error( "expected number final, got " .. type( final ) ) end
		if type( duration ) ~= "number" then return error( "expected number duration, got " .. type( duration ) ) end
		if easing and type( easing ) ~= "function" then return error( "expected function easing, got " .. type( easing ) ) end
	 -- @endif
	local frame = KeyFrame( initial, final, duration, easing )
	frame.rounded = self.rounded
	self.frames[#self.frames + 1] = frame
	return self
end

function Animation:update( dt )
	if self.frames[1] then
		self.frames[1]:update( dt )
		self.value = self.frames[1].value
		if self.frames[1]:finished() then
			table.remove( self.frames, 1 )
		end
	end
end

function Animation:finished()
	return #self.frames == 0
end
