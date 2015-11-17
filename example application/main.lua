
 -- @define SHEETS_CORE_ELEMENTS
 -- @define SHEETS_WRAP
 -- @include sheets

-- alternatively, without using Annex, use this instead:

 -- local sheets = dofile "builds/lib.lua"

-- note you can also load it as an API if using the file `builds/api.lua` under the name `sheets`

-- Create our Sheets Application
local application = sheets.Application()
-- Link the local variable 'screen' to application.screen for faster and slightly more efficient access
local screen = application.screen

function application:onLoad()
	-- Called when the application loads
	
	-- Create a new Button on our screen. Position 1, 1; width = 20; height = 5. \n is the Lua escape symbol for a newline character.
	local button = screen + sheets.Button( 1, 1, 20, 5, "I am a button.\n\nClick me." )
	-- Create a new Checkbox at position 1, 7
	local check = screen + sheets.Checkbox( 1, 7 )
	-- Create a new Text (label) at 3, 7 with width = 9; height = 1. This will appear next to the Checkbox 'check'
	local label = screen + sheets.Text( 3, 7, 9, 1, "Checkbox." )
	-- Create a new button with the label "Quit" at the top right corner of the screen
	local quit = screen + sheets.Button( screen.width - 10, 0, 10, 3, "Quit" )
	-- Create a new Sheet called key_detector.
	local key_detector = screen + sheets.Sheet( 0, 0, 0, 0 )
	-- Create a new Panel
	local panel = screen + sheets.Panel( 1, 9, 20, 5 )
	-- Create a new ScrollContainer
	local scroll = screen + sheets.ScrollContainer( 22, 1, 21, 5 )
	-- Create a new Text and add it into the ScrollContainer 'scroll'
	local text = scroll + sheets.Text( 0, 0, 20, 10, "This is a big block of text that is wordwrapped and is scrollable as it's inside a ScrollContainer." )
	-- Create a new TextInput
	local input = screen + sheets.TextInput( 22, 7, 21 )
	
	-- Set the Z-index of the first Button to 1
	button:setZ( 1 )
	
	-- Set the defaul colour of the quit Button to red
	quit.style:setField( "colour", sheets.colour.red )
	-- Set the pressed colour of the quit Button to orange
	quit.style:setField( "colour.pressed", sheets.colour.orange )
	
	-- Enable keyboard events for the key_detector Sheet
	key_detector.handlesKeyboard = true

	function button:onClick()
		-- Called when the first Button is clicked
		for i = 1, #screen.children do
			-- Loop through the screen children (all elements on screen)
			-- Link the current child through a local variable 'child' for easier access
			local child = screen.children[i]
			
			-- Animate the child's X and Y (its coordinates) to move it to a random position
			-- Choose the final coordinates so that no part of the child is offscreen
			child:animateX( math.random( 0, screen.width - child.width ) )
			child:animateY( math.random( 0, screen.height - child.height ) )
		end
	end

	function quit:onClick()
		-- Stop the application when the quit Button is clicked
		application:stop()
	end

	function key_detector:onKeyboardEvent( event )
		-- When the key_detector receives an event
		if not event.handled and event:is( sheets.event.key_down ) then
			-- And the event is a key_down event that has not been handled yet
			if event:matches "leftCtrl-t" then
				-- If the key combination matches left Ctrl + T, stop the application
				application:stop()
				-- The event now has been handled
				event:handle()
			end

		end
	end
end

-- Run our new application
application:run()
