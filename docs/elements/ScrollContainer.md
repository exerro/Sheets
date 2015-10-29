
## ScrollContainer (class)

#### extends `Sheet`

The ScrollContainer is an object that adds scrollbars to scroll its content if necessary.

> Note, this element uses the `onPreDraw()` and `onPostDraw()` callbacks.

#### Constructor

`ScrollContainer( number x, number y, number width, number height, Sheet element )`

`ScrollContainer( number x, number y, number width, number height )`

`ScrollContainer( Sheet element )`

#### Style options

- `colour` - The background colour.
- `horizontal-bar` - The colour of the horizontal bar tray.
- `horizontal-bar.bar` - The colour of the horizontal bar.
- `horizontal-bar.active` - The colour of the horizontal bar when held.
- `vertical-bar` - The colour of the vertical bar tray.
- `vertical-bar.bar` - The colour of the vertical bar.
- `vertical-bar.active` - The colour of the vertical bar when held.

#### Variables

scrollX `number`

- The current horizontal scrolling.

scrollY `number`

- The current vertical scrolling.

horizontalPadding `number`

- The padding on the right side of the content.

verticalPadding `number`

- The padding on the bottom side of the content.

#### Methods

`setScrollX( number scroll )` returns `self`

- Sets the horizontal scrolling.
- Note that a positive value increases the scrolling (moves to the right).

`setScrollY( number scroll )` returns `self`

- Sets the vertical scrolling.
- Note that a positive value increases the scrolling (moves downward).

`getContentWidth()` returns `number width`

- Returns the total width of the content, taking padding into account.

`getContentHeight()` returns `number height`

- Returns the total height of the content, taking padding into account.
