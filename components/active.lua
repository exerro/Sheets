
 -- @include component
COMPONENT(active) {
	PROPERTY(active, false) {};
 -- @include colour

COMPONENT(active) {
	PROPERTY(active, false) {};
	WITH(colour) {
		PROPERTY(active-colour, WHITE) {};
	};
}
