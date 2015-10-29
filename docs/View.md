
## View (class)

The View class is the interface between Sheet objects and an Application.

> Please note that if a setter is provided (i.e. `setX()`), use that instead of directly setting the variable.
> If you directly set `view.x`, it won't cause its parent to redraw, unlike `view:setX()`.
> If something is behaving weirdly (not updating till you click or something), this is probably what you've done.

#### Constructor

`View( number x, number y, number width, number height )`

#### Theme options

- `colour.default` - The background colour of the view.

#### Callbacks

`onUpdate( number dt )`

- Called when the view updates. Callback may be used by element. See documentation on specific elements for more information.

`onParentResized()`

- Called when the parent resizes.

#### Variables

x `number`, y `number`

- The 2D coordinates of the view.

z `number`

- The layering coordinate of the view. This can be ignored.

width `number`, height `number`

- The size of the view.

id `string`

- The ID of the view.

style `Style`

- The view's style.

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

`setStyle( Style style, boolean children = false )`

- Sets the style of the view.
- If `children` is true, it will set all child styles too.

`setCursorBlink( number x, number y, number colour = GREY )` returns `self`

- Sets the view's internal cursor blink.

`resetCursorBlink()` returns `self`

- Resets (stops) the view's internal cursor blink.

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

`animateIn( string side, optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view in from the side of the screen given.
- Valid sides are `"left"`, `"right"`, `"top"`, and `"bottom"`

`animateOut( string side, optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the view out from the side of the screen given.
- Valid sides are `"left"`, `"right"`, `"top"`, and `"bottom"`

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
