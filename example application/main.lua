
 -- @define SHEETS_CORE_ELEMENTS
 -- @define SHEETS_WRAP
 -- @include sheets

-- alternatively, without using Annex,

 -- local sheets = dofile "builds/lib.lua"

local view = sheets.application + sheets.View( 0, 0, sheets.application.width, sheets.application.height )
local button = view + sheets.Button( 1, 1, 20, 5, "I am a button.\n\nClick me." )
local check = view + sheets.Checkbox( 1, 7 )
local label = view + sheets.Text( 3, 7, 9, 1, "Checkbox." )
local quit = view + sheets.Button( view.width - 10, 0, 10, 3, "Quit" )
local key_detector = view + sheets.Sheet( 0, 0, 0, 0 )
local panel = view + sheets.Panel( 1, 9, 20, 5 )
local scroll = view + sheets.ScrollContainer( 22, 1, 21, 5 )
local text = scroll + sheets.Text( 0, 0, 20, 10, "This is a big block of text that is wordwrapped and is scrollable as it's inside a ScrollContainer." )
local input = view + sheets.TextInput( 22, 7, 21 )

button:setZ( 1 )

quit.theme:setField( quit.class, "colour", "default", sheets.colour.red )
quit.theme:setField( quit.class, "colour", "pressed", sheets.colour.orange )

key_detector.handlesKeyboard = true

function button:onClick()
	for i = 1, #view.children do
		local child = view.children[i]

		child:animateX( math.random( 0, view.width - child.width ) )
		child:animateY( math.random( 0, view.height - child.height ) )
	end
end

function quit:onClick()
	sheets.application:stop()
end

function key_detector:onKeyboardEvent( event )
	if not event.handled and event:is( sheets.event.key_down ) then

		if event:matches "leftCtrl-t" then
			sheets.application:stop()
			event:handle()
		end

	end
end

sheets.application:run()
