
# Sheets
Yet another GUI framework for ComputerCraft.

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Exerro/Sheets?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

Right now, Sheets adds in some core elements commonly used in GUIs, like buttons, text input boxes, and scrollbars.

In the future, a markup language (`Sheets Markup Language`) will be included, so entire views will be able to be loaded from an xml-like format.

> Note, this uses the [graphics library](https://github.com/Exerro/CC-Graphics-Library).
> Things from the graphics library are available under the `sheets` namespace, i.e. `sheets.Button` and `sheets.Canvas`.

Sheets is a pretty large WIP at the moment. Many more elements will be added, as well as layout helpers, SML, and an updated theming system.

### Direct graphics access.

As sheets uses the graphics library (pretty extensively), you can do pretty much anything you would with the graphics library, with the added benefit of event handling and automatic rendering.

Each sheet has its own canvas that you can draw to. Most elements leave the `onPostDraw()` callback undefined, so you can use that, or by using a plain `Sheet`, you can make use of both `onPreDraw()` and `onPostDraw()` to customise how your element looks.

This makes making games easy as pie. You can make a custom `GameRenderer` class that does completely custom drawing with any number of arbitrary shapes, and put other elements over the top. Drawing and events are both localised, so there's no complicated code to get things to work. They just work.

### Getting Started

Take a look in the `/builds` folder. To use the library as an API, download `api.lua`, or to use it as a library, download `lib.lua`

Alternatively, to use with Annex, you can download the `src` folder and place it under `sheets` in one of your include paths when building. By doing this, the library will not be localised to `sheets` by default. You'll also need to download the `src` folder of the graphics library to do this, and place that under `graphics` in one of your include paths.

### Your first application

```lua
-- Create a view to contain elements. Elements must be contained in a view.
local view = sheets.application + sheets.View( 0, 0, sheets.application.width, sheets.application.height )

-- Create a random button.
local button = view + sheets.Button( 0, 0, 20, 5, "I am a button" )

-- Make the button orange (or yellow when held)
button.style:setField( "colour", sheets.colour.orange )
button.style:setField( "colour.pressed", sheets.colour.yellow )

-- Define a function to be called when the button is clicked.
function button:onClick()
	-- Move the button to random coordinates.
	self:animateX( math.random( 0, self.parent.width - self.width ) )
	self:animateY( math.random( 0, self.parent.height - self.height ) )
end

-- Define a function to be called when the button is held.
function button:onHold()
	-- Stop the application from running.
	sheets.application:stop()
end

-- Run the application.
sheets.application:run()
```
