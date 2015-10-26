
## Theme (class)

The Theme class is used to style Sheets, Views and even entire Applications.

### SML Decoder

> Note, SML is temporarily disabled while changes are made to the core of Sheets. However, once re-implemented, this will be the case.

This element allows creation through SML, with the following syntax.

```xml
<theme name="Name"> <!-- If name is given, it is added to the SMLEnvironment of the active application -->
	<elementNameOne>
		<fieldOne stateOne=value stateTwo=value/>
		<fieldTwo stateOne=value stateTwo=value/>
	</elementNameOne>
	<elementNameTwo>
		<field stateOne=value stateTwo=value/>
	</elementNameTwo>
</theme>
```

#### Constructor

`Theme()`

#### Methods

`Theme:setField( Class class, string field, string state, * value )`

- Sets the value of a state for a field of a class. That was a tongue twister.

`Theme:getField( Class class, string field, string state )` returns `* value`

- Gets the value of a state for a field of a class. That was another tongue twister.

#### Functions (static)

`addToTemplate( Class class, string field, table states )`

- Modifies the theme template. Used internally by classes which want to have default theme values.

Example:

```lua
Theme.addToTemplate( MyCustomClass, "colour", {
	default = BLUE;
	pressed = LIGHTBLUE;
} )
```
