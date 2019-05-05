
 -- @include component

COMPONENT(scroll) {
	PROPERTY(scroll-x, 0) {
		custom_value_modification_code = "if value > self.max_scroll_x then\nvalue = self.max_scroll_x\nend\nif value < self.min_scroll_x then\nvalue = self.min_scroll_x\nend";
	};
	PROPERTY(scroll-y, 0) {
		custom_value_modification_code = "if value > self.max_scroll_y then\nvalue = self.max_scroll_y\nend\nif value < self.min_scroll_y then\nvalue = self.min_scroll_y\nend";
	};
	PROPERTY(min-scroll-x, -math.huge) {};
	PROPERTY(max-scroll-x,  math.huge) {};
	PROPERTY(min-scroll-y, -math.huge) {};
	PROPERTY(max-scroll-y,  math.huge) {};
}
