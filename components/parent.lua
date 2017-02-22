
 -- @include component

COMPONENT(parent) {
	PROPERTY(parent, nil) (
		function( self, parent )
			if parent and not class.type_of( parent, Sheet ) and not class.type_of( parent, Screen ) then
				Exception.throw( IncorrectParameterException( "expected Sheet or Screen parent, got " .. class.type( parent ), 2 ) )
			end

			return parent and parent:add_child( self ) or self:remove()
		end
	);
}
