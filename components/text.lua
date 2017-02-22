
 -- @include component
 -- @include size

 -- @define IDENT_REF(x) {type=DVALUE_IDENTIFIER,value=("x"):gsub("%-","_")}

COMPONENT(text) {
   WITH(size) {
	   ENVIRONMENT(width) {
		   auto={type=DVALUE_UNEXPR,operator="#",value=IDENT_REF(text)};
	   };
	   ENVIRONMENT(height) {
		   auto=IDENT_REF(line-count);
	   };
   };
   PROPERTY(text, "") {};
   PROPERTY(text-colour, WHITE) {};
   PROPERTY(horizontal-alignment, ALIGNMENT_LEFT) {};
   PROPERTY(vertical-alignment, ALIGNMENT_TOP) {};
   GETTER(line-count, 0);
}

 -- @unset IDENT_REF
