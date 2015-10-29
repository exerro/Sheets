
## clipboard (library)

The clipboard provides a common interface between elements to copy, cut and paste content of different types.

#### Functions

`put( table modes )`

- Writes to the clipboard, replacing what is currently there.
- The modes are a table formatted somewhat like this:

```lua
{
	["plain-text"] = "some plain text";
	["fancy-text"] = { text = "some plain text", colour = BLUE, textColour = WHITE };
}
```

`get( string mode )` returns `data`

- Gets the data of a certain mode of the clipboard.
- Using the example above, this would work:

```lua
local text = clipboard.get "plain-text"
-- text == "some plain text"
```

`clear()`

- Clears the clipboard.
