
## timer (library)

The timer library adds in methods for controlling timers and the time between frames.

#### Functions

`new( number time )` returns `number CCID`

- Returns the ComputerCraft timer ID of a timer that will fire in `time` seconds.
- Avoids duplication of timers so preferred to `os.startTimer()`.

`queue( number time, function response )` returns `number ID`

- Queues a function `response` to be called in `time` seconds, returning the ID of the timer so it can be cancelled.

`cancel( number ID )`

- Cancels a timer queued with `queue()`

`update( number CCID )`

- Updates all running timers, triggering callbacks if necessary. Takes a ComputerCraft timer ID.

> Note, this is done internally by the `Application` class.
