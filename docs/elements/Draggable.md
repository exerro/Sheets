
## Draggable (class)

#### extends `Sheet`

The Draggable is a draggable object with word wrapped text (default centre aligned).

> Note, this element uses the `onPreDraw()` callback.

#### Constructor

`Draggable( number x, number y, number width, number height, string text )`

#### Style options

- `colour` - The background colour.
- `colour.pressed` - The background colour when pressed.
- `textColour` - The text colour.
- `textColour.pressed` - The text colour when pressed.
- `horizontal-alignment` - The horizontal alignment.
- `horizontal-alignment.pressed` - The horizontal alignment when pressed.
- `vertical-alignment` - The vertical alignment.
- `vertical-alignment.pressed` - The vertical alignment when pressed.

#### Callbacks

`onDrag()`

- Called when the draggable is moved.

`onDrop()`

- Called when the draggable is dropped.

`onPickUp()`

- Called when the draggable is picked up.

`onClick( number button, number x, number y )`

- Called when the draggable is clicked.

`onHold( number button, number x, number y )`

- Called when the draggable is held.

#### Variables

text `string`

- The text shown by the draggable.

#### Methods

`setText( string text )`

- Sets the text of the draggable.
