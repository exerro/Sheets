
 -- @include component
 -- @include colour
 -- @include text

COMPONENT(toggled) {
	PROPERTY(toggled, false) {};
	WITH(colour) {
		PROPERTY(toggled-colour, WHITE) {};
	};
	WITH(text) {
		PROPERTY(toggled-text, "") {};
		PROPERTY(toggled-text-colour, GREY) {};
	}
}
