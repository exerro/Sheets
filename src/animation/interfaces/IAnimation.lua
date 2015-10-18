
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IAnimation'
 -- @endif

 -- @print Including sheets.interfaces.IAnimation

IAnimation = {}

function IAnimation:IAnimation()
	self.animations = {}
end

function IAnimation:addAnimation( label, setter, animation )
	 -- @if SHEETS_TYPE_CHECK then
	 	if type( label ) ~= "string" then return error( "expected string label, got " .. class.type( label ) ) end
	 	if type( setter ) ~= "function" then return error( "expected function setter, got " .. class.type( setter ) ) end
	 	if not class.typeOf( animation, Animation ) then return error( "expected Animation animation, got " .. class.type( animation ) ) end
	 -- @endif
	self.animations[label] = {
		setter = setter;
		animation = animation;
	}
	if animation.value then
		setter( self, animation.value )
	end
end

function IAnimation:updateAnimations( dt )
	 -- @if SHEETS_TYPE_CHECK then
	 	if type( dt ) ~= "number" then return error( "expected number dt, got " .. class.type( dt ) ) end
	 -- @endif
	local finished = {}
	local animations = self.animations
	local k, v = next( animations )

	while animations[k] do
		v.animation:update( dt )
		if v.animation.value then
			v.setter( self, v.animation.value )
		end

		if v.animation:finished() then
			if type( v.animation.onFinish ) == "function" then
				v.animation:onFinish()
			end
			finished[#finished + 1] = k
		end

		k, v = next( animations, k )
	end

	for i = 1, #finished do
		self.animations[finished[i]] = nil
	end
end
