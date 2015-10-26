
## Sheet (class)

The Sheet class is the root class of any element on the screen.

> Please note that if a setter is provided (i.e. `setX()`), use that instead of directly setting the variable.
> If you directly set `sheet.x`, it won't cause its parent to redraw, unlike `sheet:setX()`.
> If something is behaving weirdly (not updating till you click or something), this is probably what you've done.

#### Constructor

`Sheet( number x, number y, number width, number height )`

#### Callbacks

`onPreDraw()`

- Called before the sheet draws its children. Callback may be used by element. See documentation on specific elements for more information.

`onPostDraw()`

- Called after the sheet draws its children. Callback may be used by element. See documentation on specific elements for more information.

`onUpdate( number dt )`

- Called when the sheet updates. Callback may be used by element. See documentation on specific elements for more information.

`onParentResized()`

- Called when the parent resizes.

#### Variables

x `number`, y `number`

- The 2D coordinates of the sheet.

z `number`

- The layering coordinate of the sheet. This can be ignored.

width `number`, height `number`

- The size of the sheet.

id `string`

- The ID of the sheet.

theme `Theme`

- The sheet's theme.

parent `Sheet` or `View`

- The parent object of the sheet (the thing that contains it).

canvas `DrawingCanvas`

- The canvas that the object draws to.

#### Methods

`setX( x )` returns `self`

- Sets the sheet's `x` value.

`setY( y )` returns `self`

- Sets the sheet's `y` value.

`setZ( z )` returns `self`

- Sets the sheet's `z` value.

`setWidth( width )` returns `self`

- Sets the sheet's `width` value.

`setHeight( height )` returns `self`

- Sets the sheet's `height` value.

`setID( string id )`

- Sets the ID of the sheet.

`setTheme( Theme theme, boolean children = false )`

- Sets the theme of the sheet.
- If `children` is true, it will set all child themes too.

`setParent( Sheet or View parent )`

- Sets the parent of the sheet.

`setChanged( boolean state = true )` returns `self`

- Causes the sheet to redraw. No need to use this if you do everything else correctly.

`addChild( Sheet child )` returns `Sheet child`

- Adds a child to the sheet and returns it.

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

- Removes the sheet from its parent.

`isVisible()` returns `boolean visible`

- Returns whether the sheet is visible inside its parent.

`bringToFront()` returns `self`

- Brings the element to the front. Note this doesn't update the z axis, so elements with a higher z will still be in front.

`animateX( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the sheet's `x` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateY( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the sheet's `y` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateZ( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the sheet's `z` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateWidth( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the sheet's `width` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateHeight( number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3, function easing )`

- Animates the sheet's `height` value.
- Note that `easing` can also be `"transition"`, `"entrance"`, or `"exit"`.

`animateInLeft( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element in from the left side of the screen.

`animateOutLeft( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element out from the left side of the screen.

`animateInRight( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element in from the right side of the screen.

`animateOutRight( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element out from the right side of the screen.

`animateInTop( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element in from the top side of the screen.

`animateOutTop( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element out from the top side of the screen.

`animateInBottom( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element in from the bottom side of the screen.

`animateOutBottom( optional number to, number time = SHEETS_DEFAULT_TRANSITION_TIME = 0.3 )`

- Animates the element out from the bottom side of the screen.

#### Metamethods

`+` - Alias for `addChild()`.

```lua
child = sheet + Sheet( ... )
```

`..` - Adds the right value to the left value and returns the left value.

```lua
sheet = sheet .. Sheet( ... )
```

> Note, you can chain this, like below:

```lua
sheet = Sheet( x, y, w, h ) .. child1 .. child2 .. child3 .. child4
```
