
## Image (class)

#### extends `Sheet`

The Image is a clickable object with bitmap image content.

> Note, this element uses the `onPreDraw()` callback.

#### Constructor

`Image( number x, number y, string imagePath )`
`Image( number x, number y, string imageContent )`
`Image( number x, number y, table image )`

> `table image` should be formatted like `image[y][x] = { backgroundColour, textColour, character }`

#### Style options

- `shader` - The shader to apply.
- `shader.pressed` - The shader to apply when pressed.

#### Callbacks

`onClick( number button, number x, number y )`

- Called when the button is clicked.

`onHold( number button, number x, number y )`

- Called when the button is held.

#### Variables

text `string`

- The text shown by the button.
