
parameters = {}

function parameters.checkConstructor( _class, argc, ... )
	local args = { ... }
	for i = 1, argc * 3, 3 do
		local name = args[i]
		local expectedType = args[i + 1]
		local value = args[i + 2]

		if type( expectedType ) == "string" then
			if type( value ) ~= expectedType then
				Exception.throw( IncorrectConstructorException, _class:type() .. " expects " .. expectedType .. " " .. name .. " when created, got " .. class.type( value ), 4 )
			end
		else
			if not class.typeOf( value, expectedType ) then
				Exception.throw( IncorrectConstructorException, _class:type() .. " expects " .. expectedType:type() .. " " .. name .. " when created, got " .. class.type( value ), 4 )
			end
		end
	end
end

function parameters.check( argc, ... )
	local args = { ... }
	for i = 1, argc * 3, 3 do
		local name = args[i]
		local expectedType = args[i + 1]
		local value = args[i + 2]

		if type( expectedType ) == "string" then
			if type( value ) ~= expectedType then
				Exception.throw( IncorrectParameterException, "expected " .. expectedType .. " " .. name .. ", got " .. class.type( value ), 3 )
			end
		else
			if not class.typeOf( value, expectedType ) then
				Exception.throw( IncorrectParameterException, "expected " .. expectedType:type() .. " " .. name .. ", got " .. class.type( value ), 3 )
			end
		end
	end
end
