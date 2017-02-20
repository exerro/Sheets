
local param_methods = {}
local param_mt = { __index = param_methods }

local function new( ... )
	local obj = setmetatable( {}, param_mt )
	obj:new( ... )
	return obj
end

function param_methods:new()
	self.sections = {}
	self.aliases = {}
	self:add_section ":default:"
end

function param_methods:add_section( name )
	self.sections[name] = {
		type = "string";
		modifier = nil;
		validator = nil;
		lower_count = 0;
		upper_count = 0;
	}

	if not self.sections[name:sub( 1, 1 )] then
		self.aliases[name:sub( 1, 1 )] = name
	end

	return self
end

function param_methods:set_param_count( lower, upper, name )
	name = name or ":default:"
	self.sections[name].lower_count = lower or 0
	self.sections[name].upper_count = upper

	return self
end

function param_methods:set_param_type( t, name )
	name = name or ":default:"
	self.sections[name].type = t

	return self
end

function param_methods:set_param_modifier( mod, name )
	name = name or ":default:"
	self.sections[name].modifier = mod

	return self
end

function param_methods:set_param_validator( val, name )
	name = name or ":default:"
	self.sections[name].validator = val

	return self
end

function param_methods:parse( ... )
	local args = { ... }
	local section = ":default:"
	local data = { [":default:"] = {} }

	for i = 1, #args do
		if args[i]:find "^%-%-%w+" then
			local sec = args[i]:match "%w+"

			data[sec] = {}

			if self.sections[sec] then
				if self.sections[sec].lower_count ~= 0 or self.sections[sec].upper_count ~= 0 then
					section = sec
				end
			else
				error( "invalid option '" .. args[i] .. "'", 0 )
			end
		else
			if args[i]:find "^%-%w" then
				local sec = self.aliases[args[i]:sub( 2, 2 )]

				data[sec] = {}

				if self.sections[sec] then
					if self.sections[sec].lower_count ~= 0 or self.sections[sec].upper_count ~= 0 then
						section = sec
					end
				else
					error( "invalid option '" .. args[i]:sub( 1, 2 ) .. "'" )
				end

				args[i] = args[i]:sub( 3 )
			end

			if args[i] ~= "" then
				local arg = args[i]

				if self.sections[section].type == "number" then
					arg = tonumber( arg ) or error( "invalid argument '" .. arg .. "'" .. (section == ":default:" and "" or " for '--" .. section .. "'"), 0 )
				elseif self.sections[section].type == "bool" then
					if arg:lower() == "true" or arg:lower() == "yes" or arg == "y" or arg == "Y" then
						arg = true
					elseif arg:lower() == "false" or arg:lower() == "no" or arg == "n" or arg == "N" then
						arg = false
					else
						error( "invalid argument '" .. arg .. "'" .. (section == ":default:" and "" or " for '--" .. section .. "'"), 0 )
					end
				end

				if self.sections[section].modifier then
					arg = self.sections[section].modifier( arg )
				end

				if self.sections[section].validator then
					local ok, err = self.sections[section].validator( arg )

					if not ok then
						error( "invalid argument '" .. tostring( arg ) .. "'" .. (section == ":default:" and "" or " for '--" .. section .. "'") .. ": " .. err, 0 )
					end
				end

				data[section][#data[section] + 1] = arg

				if self.sections[section].upper_count and #data[section] > self.sections[section].upper_count then
					section = ":default:"
				end
			end
		end
	end

	for i = 1, #data[":default:"] do
		data[i] = data[":default:"][i]
	end

	for k, v in pairs( self.sections ) do
		local kn = k == ":default:" and "" or " for '--" .. k .. "'"
		if not data[k] and v.lower_count ~= 0 then
			return error( "expected parameters" .. kn, 0 )
		elseif data[k] and #data[k] < v.lower_count then
			return error( "expected at least " .. v.lower_count .. " parameters" .. kn .. ", got " .. #data[k], 0 )
		elseif data[k] and v.upper_count and #data[k] > v.upper_count then
			return error( "expected at most " .. v.upper_count .. " parameters" .. kn .. ", got " .. #data[k], 0 )
		end

		if v.lower_count == 0 and v.upper_count == 0 then
			data[k] = data[k] ~= nil
		elseif v.upper_count == 1 then
			data[k] = data[k] and data[k][1]
		else
			data[k] = data[k] or {}
		end
	end

	return data
end

return new
