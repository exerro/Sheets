
 -- @private
 -- @localise component
component = {}

-- @private
-- @localise components
components = {}

 -- @define COMPONENT(name) components.name=(function(data)data.property='name';data.__component=true return data end)
 -- @define PROPERTY(name, def) (function(flags)return{type="property",property='name',default=def,options=options}end)
 -- @define GETTER(name, def) {type="getter",property='name',default=def}
 -- @define SETTER(name) {type="setter",property='name'}
 -- @define ENVIRONMENT(name) (function(env)return{type="environment",property='name',environment=env}end)
 -- @define WITH(name) (function(data)return{type="dependency",component='name',data=data}end)

local function add_data_t( res, data, lookup, src )
	for i = 1, #data do
		if data[i].type == "property" or data[i].type == "getter" or data[i].type == "setter" then
			print( data[i].property, data[i].default )
			if res[data[i].property] then
				error( "conflicting property name '" .. data[i].property .. "' from components '" .. src.property .. "' and '" .. res[data[i].property].from.property .. "'" )
			else
				res[data[i].property] = { type = data[i].type, from = src, name = data[i].property, environment = {}, default = data[i].default }
			end
		elseif data[i].type == "environment" then
			if res[data[i].property] then
				print( data[i].property )
			else
				error( "no such property '" .. data[i].property .. "'" )
			end
		elseif data[i].type == "dependency" then
			if lookup[components[data[i].component]] then
				add_data_t( res, data[i].data, lookup, src )
			end
		end
	end
end

function components.combine(...)
	local c = { ... }
	local lookup = {}
	local properties = {}

	table.sort( c, function( a, b )
		local function depends( t, d )
			for i = 1, #t do
				if t[i].type == "dependency" then
					if t[i].component == d or depends( t[i].data, d ) then
						return true
					end
				end
			end
		end

		if depends( a, b ) then
			return false
		elseif depends( b, a ) then
			return true
		end

		return a.property < b.property
	end )

	for i = 1, #c do
		lookup[c[i]] = true
	end

	for i = 1, #c do
		add_data_t( properties, c[i], lookup, c[i] )
	end

	return properties
end

do
	COMPONENT(a) {
		PROPERTY(x, 0) {};
		ENVIRONMENT(x) {};
	}
	COMPONENT(b) {
		WITH(a) {
			ENVIRONMENT(x) {}
		}
	}
	COMPONENT(c) {
		PROPERTY(y, 1) {}
	}
	COMPONENT(d) {
		WITH(a) {
			WITH(c) {
				ENVIRONMENT(y) {};
			};
			ENVIRONMENT(x) {};
			PROPERTY(x, 1) {};
		}
	}

	components.combine( components.d, components.c, components.a, components.b )
end
