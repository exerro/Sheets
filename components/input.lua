
 -- @include component

COMPONENT(input) {
	WITH(text) {
		PROPERTY(hint-text, "") {

		};
		ENVIRONMENT(hint-text) {
			default = "insert text...";
		};
		WITH(colour) {
			PROPERTY(hint-text-colour, WHITE) {};

			ENVIRONMENT(hint-text-colour) {
				match = { type = DVALUE_IDENTIFIER, value = "text_colour" }
			};

			WITH(active) {
				PROPERTY(active-hint-text-colour, WHITE) {};
				ENVIRONMENT(active-hint-text-colour) {
					match = { type = DVALUE_IDENTIFIER, value = "active_text_colour" };
				};
			};
		};
	};
}
