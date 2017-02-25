
 -- @print including(lib.lifetime)

 -- @localise lifetimelib
lifetimelib = {}

function lifetimelib.destroy( lifetime )
	for i = #lifetime, 1, -1 do
		local l = lifetime[i]
		if l[1] == "value" then
			l[2]:unsubscribe( l[3], l[4] )
		elseif l[1] == "query" then
			l[2]:unsubscribe( l[3], l[4] )
		elseif l[1] == "tag" then
			l[2]:unsubscribe_from_tag( l[3], l[4] )
		end
	end
end

function lifetimelib.get_value_references( l )
	local t = {}
	local idx = 0

	for i = 1, #l do
		if l[i][1] == "value" then
			idx = idx + 1
			t[idx] = { l[i][2], l[i][3] }
		end
	end

	return t
end
