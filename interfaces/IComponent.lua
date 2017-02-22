
 -- @include components.component

 -- @print including(interfaces.IComponent)

@interface IComponent {
	properties = {};
}

function IComponent:initialise_properties() -- function overridden by IComponent:add_components()
	return error( "Class has not defined IComponent:add_components()", 0 )
end

function IComponent:add_components( ... )
	local comp = { ... }

	for i = 1, #comp do
		if type( comp[i] ) == "string" then
			comp[i] = components[comp[i]] or error( "component '" .. comp[i] .. "' could not be resolved", 2 )
		elseif type( comp[i] ) ~= "table" or not comp[i].__component then
			return error( "expected component, got " .. class.type( comp[i] ) )
		end
	end

	local properties = component.combine( unpack( comp ) )

	for k, v in pairs( properties ) do
		print( k )
	end
end
