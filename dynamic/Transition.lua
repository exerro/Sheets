
class "Transition" {
	duration = 0.4;
	easing_function = nil;
}

function Transition:Transition( easing, duration )
	self.easing_function = easing
	self.duration = duration or self.duration
end

Transition.none = nil

Transition.linear = Transition( Easing.linear, 0.4 )
Transition.linear_slow = Transition( Easing.linear, 0.8 )
Transition.linear_fast = Transition( Easing.linear, 0.2 )

Transition.smooth = Transition( Easing.smooth, 0.4 )
Transition.smooth_slow = Transition( Easing.smooth, 0.8 )
Transition.smooth_fast = Transition( Easing.smooth, 0.2 )

Transition.entrance = Transition( Easing.entrance, 0.4 )
Transition.entrance_slow = Transition( Easing.entrance, 0.8 )
Transition.entrance_fast = Transition( Easing.entrance, 0.2 )

Transition.exit = Transition( Easing.exit, 0.4 )
Transition.exit_slow = Transition( Easing.exit, 0.8 )
Transition.exit_fast = Transition( Easing.exit, 0.2 )
