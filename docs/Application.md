
## Application (class)

The Application class is the root node of any program. It handles events, rendering, and contains Views.

### The Application viewport

Imagine all the views of an application are layed out on the floor. There is a large sheet of paper placed on top of them, with a small rectangle (the size of the screen) cut out of it. That hole is the viewport. What you see on the screen and interact with is what is directly under the viewport. You can move the viewport around and see different things, but the viewport never changes size unless the screen resizes.

You can use this to make fancy animations that go between views (see `transitionViewport()`), making the interface easy to understand by the user.

#### Constructor

`Application()`

#### Variables

name `string`

- The name of the application.

path `string`

- The path to application files.

width `number`

- The width of the application. This is updated automatically on term_resize events.

height `number`

- The height of the application. This is updated automatically on term_resize events.

terminateable `boolean`

- Whether or not the application will stop on a terminate event.

running `boolean`

- Whether the application is currently running. See `stop()`.

viewportX `number`

- The X position of the viewport (positive is further left). See `transitionViewport()`.

viewportY `number`

- The Y position of the viewport (positive is further down). See `transitionViewport()`.

screen `ScreenCanvas`

- The canvas of the application where everything is eventually drawn to.

#### Methods

`stop()`

- Stops the application.

`transitionViewport( optional number x, optional number y )` returns `Animation x (if dx>0), Animation y (if dy>0)`

- Moves the application viewport to the new coordinates, if given. Returns the animation of each axis if there is a difference between the new and old coordinates of each axis.

`transitionViewTo( View view )` returns `Animation x (if dx>0), Animation y (if dy>0)`

- Moves the application viewport to the coordinates of the view given. See `transitionViewport()` for more information.

`addTerminal( table redirect )` returns `self`

- Adds a terminal redirect to draw to.

`removeTerminal( table redirect )` returns `self`

- Removes a terminal redirect previously added.

`addMonitor( string side )` returns `self`

- Adds a monitor (both event handling and drawing)

`removeMonitor( string side )` returns `self`

- Removes a monitor previously added.

`addChild( View child )` returns `View child`

- Adds a view to the application.

`removeChild( View child )` returns `View child`

- Removes a child.

`getChildById( string id )` returns `View/Sheet/nil child`

- Returns the first child with the given id, or nil if there is no child with that id.

`getChildrenById( id )` returns `table children`

- Returns a list of all children with the given id.

`getChildrenAt( number x, number y )` returns `table children`

- Returns a list of all children at the given coordinates, with the first being on top, and last being on bottom.

`isChildVisible( View child )`

- Returns whether the view given is visible. (Note this only pays position into account, not parenting)

`run()`

- Correctly runs the application, handling updates, drawing, and events.

`setChanged( boolean state = true )`

- Used tell the application it needs to redraw. If you've done something weird to the application and it isn't updating, use this.

`event( string event, ... )`

- Passes an event to the children of the application or updates timers. Used internally by `run()`.

`update()`

- Updates the children of the application and steps the timer. Used internally by `run()`.

`draw()`

- Draws the children of the application and draws to the screen. Used internally by `run()`.

#### Metamethods

`+` - Alias for `addChild()`.

```lua
child = application + View( ... )
```

`..` - Adds the right value to the left value and returns the left value.

```lua
application = application .. View( ... )
```

> Note, you can chain this, like below:

```lua
application = application .. view1 .. view2 .. view3 .. view4
```
