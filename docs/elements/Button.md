
## Button (class)

#### extends `Sheet`

The Button is a clickable object with word wrapped text (default centre aligned).

> Note, this element uses the `onPreDraw()` callback.

#### Constructor

`Button( number x, number y, number width, number height, string text )`

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

`onClick( number button, number x, number y )`

- Called when the button is clicked.

`onHold( number button, number x, number y )`

- Called when the button is held.

#### Variables

text `string`

- The text shown by the button.

#### Methods

`setText( string text )`

- Sets the text of the button.
