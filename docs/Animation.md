
## Animation (class)

The Animation class is used to handle the animation of single values with multiple keyframes and pauses.

There are two other classes, `KeyFrame` and `Pause` linked to this, but as they are purely internal, are not documented.

The only interaction you could need to have with these is to give them `onFinish()` callbacks or check if they are `finished()`, both of which are mentioned below.

Animations should not be modified during execution, or any time after initial set up really.

#### Callbacks

`onFinish( Animation self )`

- Called when the animation has finished.

`onFrameFinished( Animation self, number frame )`

- Called when a frame finishes.

#### Variables

rounded `boolean`

- Whether the value of the animation should be rounded.

#### Methods

`addKeyFrame( number initial, number target, number duration, function easing )` returns `self`

- Adds a keyframe (range to be animated) to the end of the animation.

> Note, `easing` can also be SHEETS_EASING_TRANSITION, SHEETS_EASING_ENTRANCE, or SHEETS_EASING_EXIT

`addPause( number duration )` return `self`

- Adds a pause to the end of the animation.

`setRounded( bool rounded = true )` returns `self`

- Sets whether the value of the animation should be rounded.

`update( number dt )`

- Advances the animation by `dt` seconds.

`finished()` returns `boolean finished`

- Returns whether the animation has finished.

> Note, frames and pauses also have this method, meaning you can asses which parts of the animation have finished.
