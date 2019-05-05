
 -- @include component
 -- @include size
 -- @include input
 -- @include active

 -- @define IDENT_REF(x) {type=DVALUE_IDENTIFIER,value=("x"):gsub("%-","_")}

COMPONENT(text) {
	-- text and text colour properties
	PROPERTY(text, "") {};
	PROPERTY(text-colour, GREY) {};
	-- alignment properties
	PROPERTY(horizontal-alignment, ALIGNMENT_LEFT) {};
	PROPERTY(vertical-alignment, ALIGNMENT_TOP) {};
	-- line count getter
	GETTER(line-count, 0);

	-- with size, width and height get 'auto' property
	WITH(size) {
		ENVIRONMENT(width) {
			auto={type=DVALUE_UNEXPR,operator="#",value=IDENT_REF(text)};
		};
		ENVIRONMENT(height) {
			auto=IDENT_REF(line-count);
		};
	};

	WITH(active) {
		PROPERTY(active-text-colour, GREY) {};
		WITHOUT(input) {
			PROPERTY(active-text, "") {};
		}
	};
}

 -- @unset IDENT_REF
