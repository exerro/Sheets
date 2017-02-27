
 -- @private
 -- @localise component
component = {}

-- @private
-- @localise components
components = {}

 -- @define COMPONENT(name) components.name=(function(data)data.property='name';data.__component=true return data end)
 -- @define PROPERTY(name, def) (function(flags)return{type="property",property=('name'):gsub("%-","_"),default=def,options=flags}end)
 -- @define GETTER(name, def) {type="getter",property=('name'):gsub("%-","_"),default=def}
 -- @define SETTER(name) {type="setter",property=('name'):gsub("%-","_")}
 -- @define ENVIRONMENT(name) (function(env)return{type="environment",property=('name'):gsub("%-","_"),environment=env}end)
 -- @define WITH(name) (function(data)return{type="dependency",component='name',data=data}end)
 -- @define ENABLE_PERCENTAGES(ast) percentages_enabled=true; percentage_ast=ast

local function add_data_t( res, changed, data, lookup, src )
	for i = 1, #data do
		if data[i].type == "property" or data[i].type == "getter" or data[i].type == "setter" then
			if res[data[i].property] then
				for k, v in pairs( res[data[i].property] ) do
					print( k, tostring( v ) )
				end
				error( "conflicting property name '" .. data[i].property .. "' from components '" .. src.property .. "' and '" .. res[data[i].property].from.property .. "'" )
			else
				res[data[i].property] = { type = data[i].type, from = src, name = data[i].property, environment = {}, default = data[i].default, options = data[i].options }
				changed[data[i].property] = true
			end
		elseif data[i].type == "environment" then
			if res[data[i].property] then
				local env = res[data[i].property].environment

				for k, v in pairs( data[i].environment ) do
					env[k] = v
				end

				changed[data[i].property] = true
			else
				error( "no such property '" .. data[i].property .. "'" )
			end
		elseif data[i].type == "dependency" then
			if lookup[components[data[i].component]] then
				add_data_t( res, changed, data[i].data, lookup, src )
			end
		end
	end
end

function component.combine( properties, lookup, ... )
	local c = { ... }
	local changed = {}

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
		add_data_t( properties, changed, c[i], lookup, c[i] )
	end

	return changed
end
