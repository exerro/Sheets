
## Checkbox (class)

#### extends `Sheet`

The Checkbox is a 1x1 clickable object that toggles a check (`"x"`) in its centre.

> Note, this element uses the `onPreDraw()` callback.

#### Constructor

`Button( number x, number y, boolean checked = false )`

#### Theme options

- `colour.default` - The background colour.
- `colour.checked` - The background colour when checked.
- `colour.pressed` - The background colour when pressed.
- `textColour.default` - The text colour.
- `textColour.pressed` - The text colour when pressed.

#### Callbacks

`onToggle( number button, number x, number y )`

- Called when the checkbox is toggled.

`onCheck()`

- Called when the button is checked (in addition to `onToggle()`).

`onUnCheck()`

- Called when the button is unchecked (in addition to `onToggle()`).

#### Variables

checked `boolean`

- Whether the checkbox is checked.

#### Methods

`toggle()`

- Toggles the state of the checkbox.
