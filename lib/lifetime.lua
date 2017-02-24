
 -- @print including(lib.lifetime)

 -- @localise lifetime
lifetime = {}

function lifetime.destroy( l )
	for i = #l, 1, -1 do
		if l[1] == "value" then
			l[2]:unsubscribe( l[3], l[4] )
		elseif l[1] == "query" then
			l[2]:unsubscribe( l[3], l[4] )
		elseif l[1] == "tag" then
			l[2]:unsubscribe_from_tag( l[3], l[4] )
		end
	end
end
