# Defold Timer
Defold Timer (dtimer) provides a visual timer widget in a Defold game engine project.

An [example project](https://github.com/klaytonkowalski/defold-timer/tree/master/example) is available if you need additional help with configuration.  
Visit my [Giphy](https://media.giphy.com/media/YFnSgIm0DdVJmTmN3N/giphy.gif) to see an animated gif of the example project.

Please click the "Star" button on GitHub if you find this asset to be useful!

![alt text](https://github.com/klaytonkowalski/defold-timer/blob/master/assets/thumbnail.png?raw=true)

## Installation
To install dtimer into your project, add one of the following links to your `game.project` dependencies:
  - https://github.com/klaytonkowalski/defold-timer/archive/master.zip
  - URL of a [specific release](https://github.com/klaytonkowalski/defold-timer/releases)

## Configuration
Import the dtimer Lua module into your relevant gui scripts:  
`local dtimer = require "dtimer.dtimer"`

In many games, there exists some kind of on-screen timer counting up or down to track the player's rate of progression through a level or scenario. The elapsed time can then be used for various purposes, for example saving the player's fastest attempt at a level or restarting a level when time runs out.

This library only handles timer logic and setting the text of a gui node with `gui.set_text()`. The user retains all styling authority over their gui nodes. These philosophies allow for simplicity, robustness, and separation of concerns.

Timers used in `dtimer` hold four components: hours, minutes, seconds, and centiseconds. The user can specify which of these components to display in their gui nodes. Leading zeros are displayed appropriately.

See the following code for a basic scenario of starting a timer, stopping it after some amount of seconds, then printing its full timestamp:

```

```

## API

### dtimer.add_node(node_id, format)

Adds a gui node to the timer system.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `format`: Table that specifies which timestamp components to display:

```
{
    hours = false,
    minutes = true,
    seconds = true,
    centiseconds = false
}
```

If `format` is `nil`, then the above default will be used.

---

### dtimer.remove_node(node_id)

Removes a node from the timer system.

#### Parameters
1. `node_id`: Hashed id of a gui node.

#### Returns

Returns the elapsed time in seconds.

---

### dtimer.set_format(node_id, format)

Sets the format of a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `format`: Table that specifies which timestamp components to display:

```
{
    hours = false,
    minutes = true,
    seconds = true,
    centiseconds = false
}
```

---

### dtimer.get_elapsed(node_id)

Gets the elapsed time of a node in seconds.

#### Parameters
1. `node_id`: Hashed id of a gui node.

#### Returns
Return a `number`.

---

### dtimer.get_timestamp(node_id)

Gets a verbose timestamp of a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.

#### Returns
Return a table in the following format:

```
{
    hours = <number>,
    minutes = <number>,
    seconds = <number>,
    centiseconds = <number>
}
```

---

### dtimer.is_enabled(node_id)

Checks if the timer attached to a node is running.

#### Parameters
1. `node_id`: Hashed id of a gui node.

#### Returns

Returns `true` or `false`.

---

### dtimer.start(node_id, reset)

Starts the timer attached to a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `reset`: `bool` if the timer should reset to zero.

#### Returns

Returns the elapsed time.

---

### dtimer.stop(node_id, reset)

Stops the timer attached to a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `reset`: `bool` if the timer should reset to zero.

#### Returns

Returns the elapsed time.

---

### dtimer.toggle(node_id, reset)

Toggles the timer attached to a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `reset`: `bool` if the timer should reset to zero.

#### Returns

Returns the elapsed time.

---

### dtimer.update(dt)

Updates all timers and displays. Should be called in the `update(self, dt)` function of your gui script.

#### Parameters
1. `dt`: Time elapsed since last frame.
