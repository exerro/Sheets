
## TextInput (class)

#### extends `Sheet`

The TextInput is a clickable object with word wrapped text (default centre aligned).

> Note, this element uses the `onPreDraw()` callback.

#### Constructor

`TextInput( number x, number y, number width, number height, string text )`

#### Theme options

- `colour.default` - The background colour.
- `colour.focussed` - The background colour when focussed.
- `colour.highlighted` - The background colour of highlighted text.
- `textColour.default` - The text colour.
- `textColour.focussed` - The text colour when focussed.
- `textColour.highlighted` - The text colour of highlighted text.
- `mask.default` - The text masking.
- `mask.focussed` - The text masking when focussed.

#### Callbacks

`onEnter()`

- Called when enter is pressed while the input is focussed.
- The input will have defocussed when this is called.

`onTab()`

- Called when tab is pressed while the input is focussed.
- The input will have defocussed when this is called.

`onFocus()`

- Called when the input is focussed on.

`onUnFocus()`

- Called when the input is unfocussed from.

#### Variables

text `string`

- The text shown by the input.

scroll `number`

- The current horizontal scrolling of the input.

focussed `boolean`

- Whether the input is currently focussed.

#### Methods

`setText( string text )` returns `self`

- Sets the text of the input.

`setScroll( number scroll )` returns `self`

- Sets the horizontal scroll of the input.

`setCursor( number cursor )` returns `self`

- Sets the cursor position of the input and handles scrolling.

`setSelection( number position )` returns `self`

- Sets the selection position of the input.

`getSelectedText()` returns `string text` or `false`

- Returns the selected text of the input, or false if nothing is selected.

`write( string text )` returns `self`

- Writes text to the input, replacing selected text if necessary, and updating the cursor position.

`focus()` returns `self`

- Focusses on the element, invoking callbacks.

`unfocus()` returns `self`

- Unfocusses from the element, invoking callbacks.
