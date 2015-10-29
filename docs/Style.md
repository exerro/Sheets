
## Style (class)

The Style class is used to style Sheets, Views and other elements.

#### SML Decoder

> Note, SML is temporarily disabled while changes are made to the core of Sheets. However, once re-implemented, this will be the case.

This element allows creation through SML, with the following syntax.

```xml
<style name="Name">
	button {
		colour: red;
	}
	button .pressed {
		textColour: pink;
	}
</style>
```

#### Field names

Field names are formatted as such: `field`, or `field.state`. If no state is given, `"default"` is used, so `field` -> `field.default`.

An example field name is `colour.pressed` for a button colour when pressed.

#### Constructor

`Style( Sheet/View object )`

#### Methods

`Style:setField( string field, * value )`

- Sets the value of a field.

`Style:getField( string field )` returns `* value`

- Gets the value of a field.

#### Functions (static)

`addToTemplate( Class class, table fields )`

- Modifies the style template. Used internally by classes which want to have default style values.

Example:

```lua
Style.addToTemplate( MyCustomClass, {
	["colour"] = BLUE;
	["colour.default"] = LIGHTBLUE;
} )
```
