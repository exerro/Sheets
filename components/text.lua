
 -- @include component
 -- @include size

COMPONENT(text) {
   WITH(size) {
	   ENVIRONMENT(width) { auto = auto_width };
	   ENVIRONMENT(height) { auto = auto_height };
   };
   PROPERTY(text, "") {};
   PROPERTY(text_colour, WHITE) {};
   PROPERTY(horizontal_alignment, ALIGNMENT_LEFT) {};
   PROPERTY(vertical_alignment, ALIGNMENT_TOP) {};
   RPROPERTY(line_count, 0);
}
