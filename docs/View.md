
## View (class)

The View class is the interface between Sheet objects and an Application.

> Please note that if a setter is provided (i.e. `setX()`), use that instead of directly setting the variable.
> If you directly set `sheet.x`, it won't cause its parent to redraw, unlike `sheet:setX()`.
> If something is behaving weirdly (not updating till you click or something), this is probably what you've done.

#### Constructor

`View( number x, number y, number width, number height )`

#### Callbacks

`onUpdate( number dt )`

- Called when the view updates. Callback may be used by element. See documentation on specific elements for more information.

#### Variables

x `number`, y `number`

- The 2D coordinates of the view.

z `number`

- The layering coordinate of the view. This can be ignored.

width `number`, height `number`

- The size of the view.

id `string`

- The ID of the view.

theme `Theme`

- The view's theme.

parent `Application`

- The parent object of the view (the thing that contains it).

canvas `DrawingCanvas`

- The canvas that the object draws to.

#### Methods

`setX( x )` returns `self`

- Sets the view's `x` value.

`setY( y )` returns `self`

- Sets the view's `y` value.

`setZ( z )` returns `self`

- Sets the view's `z` value.

`setWidth( width )` returns `self`

- Sets the view's `width` value.

`setHeight( height )` returns `self`

- Sets the view's `height` value.

`setID( string id )`

- Sets the ID of the view.

`setTheme( Theme theme, boolean children = false )`

- Sets the theme of the view.
- If `children` is true, it will set all child themes too.

`setParent( Application parent )`

- Sets the parent of the view.

`setChanged( boolean state = true )` returns `self`

- Causes the view to redraw. No need to use this if you do everything else correctly.

`addChild( Sheet child )` returns `Sheet child`

- Adds a child to the view and returns it.

`removeChild( Sheet child )` returns `Sheet child`

- Removes a child and returns it if removed.

`getChildById( string id )` returns `Sheet/nil child`

- Returns the first child with the given id, or nil if there is no child with that id.

`getChildrenById( id )` returns `table children`

- Returns a list of all children with the given id.

`getChildrenAt( number x, number y )` returns `table children`

- Returns a list of all children at the given coordinates, with the first being on top, and last being on bottom.

`isChildVisible( Sheet child )` returns `boolean visible`

- Returns whether the child is visible within the bounds of the sheet content. (Note this only pays position into account, not parenting)

`remove()`

- Removes the view from its parent.

`isVisible()` returns `boolean visible`

- Returns whether the view is visible inside its parent.

`bringToFront()` returns `self`

- Brings the element to the front. Note this doesn't update the z axis, so elements with a higher z will still be in front.

`animateX( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the view's `x` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateY( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the view's `y` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateZ( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the view's `z` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateWidth( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the view's `width` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateHeight( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the view's `height` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateInLeft( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view in from the left side of the screen.

`animateOutLeft( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view out from the left side of the screen.

`animateInRight( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view in from the right side of the screen.

`animateOutRight( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view out from the right side of the screen.

`animateInTop( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view in from the top side of the screen.

`animateOutTop( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view out from the top side of the screen.

`animateInBottom( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view in from the bottom side of the screen.

`animateOutBottom( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view out from the bottom side of the screen.

#### Metamethods

`+` - Alias for `addChild()`.

```lua
child = view + Sheet( ... )
```

`..` - Adds the right value to the left value and returns the left value.

```lua
view = view .. Sheet( ... )
```

> Note, you can chain this, like below:

```lua
view = View( x, y, w, h ) .. child1 .. child2 .. child3 .. child4
```
