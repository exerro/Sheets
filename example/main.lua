
local sheets = dofile "builds/lib.lua"
-- note you can also load it as an API if using the file `builds/api.lua` under the name `sheets`

local application = sheets.Application()
local screen = application.screen

function application:onLoad()
	local button = screen + sheets.Button( 1, 1, 20, 5, "I am a button.\n\nClick me." )
	local check = screen + sheets.Checkbox( 1, 7 )
	local label = screen + sheets.Text( 3, 7, 9, 1, "Checkbox." )
	local quit = screen + sheets.Button( screen.width - 10, 0, 10, 3, "Quit" )
	local key_detector = screen + sheets.Sheet( 0, 0, 0, 0 )
	local panel = screen + sheets.Panel( 1, 9, 20, 5 )
	local scroll = screen + sheets.ScrollContainer( 22, 1, 21, 5 )
	local text = scroll + sheets.Text( 0, 0, 20, 10, "This is a big block of text that is wordwrapped and is scrollable as it's inside a ScrollContainer." )
	local input = screen + sheets.TextInput( 22, 7, 21 )

	button:setZ( 1 )

	quit.style:setField( "colour", sheets.colour.red )
	quit.style:setField( "colour.pressed", sheets.colour.orange )

	key_detector.handlesKeyboard = true

	function button:onClick()
		for i = 1, #screen.children do
			local child = screen.children[i]

			child:animateX( math.random( 0, screen.width - child.width ) )
			child:animateY( math.random( 0, screen.height - child.height ) )
		end
	end

	function quit:onClick()
		application:stop()
	end

	function key_detector:onKeyboardEvent( event )
		if not event.handled and event:is( sheets.event.key_down ) then

			if event:matches "leftCtrl-t" then
				application:stop()
				event:handle()
			end

		end
	end
end

application:run()
