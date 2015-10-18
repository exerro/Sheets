
 -- @once

 -- @ifndef __INCLUDE_sheets
	-- @error 'sheets' must be included before including 'sheets.interfaces.IAnimationContainer'
 -- @endif

 -- @print Including sheets.interfaces.IAnimationContainer

IAnimationContainer = {}

function IAnimationContainer:IAnimationContainer()
	self.animations = {}
end

function IAnimationContainer:addAnimation( label, setter, animation )
	self.animations[label] = {
		setter = setter;
		animation = animation;
	}
	setter( self, animation.value )
end

function IAnimationContainer:updateAnimations( dt )
	local finished = {}
	local animations = self.animations
	local k, v = next( animations )

	while animations[k] do
		v.animation:update( dt )
		v.setter( self, v.animation.value )

		if v.animation:finished() then
			finished[#finished + 1] = k
		end

		k, v = next( animations, k )
	end

	for i = 1, #finished do
		self.animations[finished[i]] = nil
	end
end
