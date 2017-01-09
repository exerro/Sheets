
parameters = {}

function parameters.check_constructor( _class, argc, ... )
	local args = { ... }
	for i = 1, argc * 3, 3 do
		local name = args[i]
		local expected_type = args[i + 1]
		local value = args[i + 2]

		if type( expected_type ) == "string" then
			if type( value ) ~= expected_type then
				Exception.throw( IncorrectConstructorException, _class:type() .. " expects " .. expected_type .. " " .. name .. " when created, got " .. class.type( value ), 4 )
			end
		else
			if not class.type_of( value, expected_type ) then
				Exception.throw( IncorrectConstructorException, _class:type() .. " expects " .. expected_type:type() .. " " .. name .. " when created, got " .. class.type( value ), 4 )
			end
		end
	end
end

function parameters.check( argc, ... )
	local args = { ... }
	for i = 1, argc * 3, 3 do
		local name = args[i]
		local expected_type = args[i + 1]
		local value = args[i + 2]

		if type( expected_type ) == "string" then
			if type( value ) ~= expected_type then
				Exception.throw( IncorrectParameterException, "expected " .. expected_type .. " " .. name .. ", got " .. class.type( value ), 3 )
			end
		else
			if not class.type_of( value, expected_type ) then
				Exception.throw( IncorrectParameterException, "expected " .. expected_type:type() .. " " .. name .. ", got " .. class.type( value ), 3 )
			end
		end
	end
end