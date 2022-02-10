# Defold Timer
Defold Timer (dtimer) provides a visual timer widget in a Defold game engine project.

An [example project](https://github.com/klaytonkowalski/defold-timer/tree/main/example) is available if you need additional help with configuration.  
Visit my [Giphy](https://media.giphy.com/media/4tCpsy4ne4mBv7aYHF/giphy.gif) to see an animated gif of the example project.

Please click the "Star" button on GitHub if you find this asset to be useful!

![alt text](https://github.com/klaytonkowalski/defold-timer/blob/main/assets/thumbnail.png?raw=true)

## Installation
To install dtimer into your project, add one of the following links to your `game.project` dependencies:
  - https://github.com/klaytonkowalski/defold-timer/archive/main.zip
  - URL of a [specific release](https://github.com/klaytonkowalski/defold-timer/releases)

## Configuration
Import the dtimer Lua module into your relevant gui scripts:  
`local dtimer = require "dtimer.dtimer"`

In many games, there exists some kind of on-screen timer counting up or down to track the player's rate of progression through a level or scenario. The elapsed time can then be used for various purposes, for example saving the player's fastest attempt at a level or restarting a level when time runs out.

This library only handles timer logic and setting the text of a gui node with `gui.set_text()`. The user retains all styling authority over their gui nodes. These philosophies allow for simplicity, robustness, and separation of concerns.

Timers used in `dtimer` hold four components: hours, minutes, seconds, and centiseconds. The user can specify which of these components to display in their gui nodes. Leading zeros are displayed appropriately.

See the following code for a basic usage scenario:

```
local dtimer = require "dtimer.dtimer"

-- Hash of gui node id.
local node_timer = hash("node_timer")

function init(self)
    msg.url(msg.url(), hash("acquire_input_focus"))
    dtimer.set_url(msg.url())
    -- Count up to 1 hour and display all timestamp components.
    dtimer.add_node(node_timer, true, { hours = true, minutes = true, seconds = true, centiseconds = true }, 3600)
    dtimer.start(node_timer)
end

function update(self, dt)
    dtimer.update(dt)
end

function on_message(self, message_id, message, sender)
    if message_id == dtimer.messages.start then
        -- If timer starts, turn node green.
        gui.set_color(gui.get_node(message.node_id), vmath.vector4(0, 1, 0, 1))
    elseif message_id == dtimer.messages.stop then
        -- If timer stops and limit is reached, turn node red.
        -- If timer stops and limit is not reached or no limit exists, turn node yellow.
        gui.set_color(gui.get_node(message.node_id), message.complete and vmath.vector4(1, 0, 0, 1) or vmath.vector4(1, 1, 0, 1))
    end
end
```

## API: Properties

### dtimer.messages

Table of hashes which are sent to the `on_message()` function of the corresponding gui script:

```
dtimer.messages
{
    start = hash("dtimer_start"),
    stop = hash("dtimer_stop")
}
```

`start`: Sent when a timer starts. The `message` table contains the following:

```
{
    node_id = <hash>,
    elapsed = <number> -- Starting value of the timer in seconds.
}
```

`stop`: Sent when a timer stops. The `message` table contains the following:

```
{
    node_id = <hash>,
    elapsed = <number>, -- Stopping value of the timer in seconds.
    complete = <bool> -- If the timer reached its `duration` limit.
}
```

## API: Functions

### dtimer.add_node(node_id, increasing, [format], [duration])

Adds a gui node to the timer system. Timers begin in the stopped state.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `increasing`: `bool` if timer should count up or down.
3. `[format]`: Table that specifies which timestamp components to display:

```
{
    hours = false,
    minutes = true,
    seconds = true,
    centiseconds = false
}
```

If `format` is `nil`, then the above default will be used.

4. `[duration]`: Maximum elapsed seconds counting up from zero or start time counting down to zero. This argument is required if `increasing` is `false`.

---

### dtimer.remove_node(node_id)

Removes a node from the timer system.

#### Parameters
1. `node_id`: Hashed id of a gui node.

---

### dtimer.start(node_id, [reset])

Starts the timer attached to a node. If the timer is already started and `reset` is `true`, then its elapsed time will reset and continue counting without stopping.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `[reset]`: `bool` if the timer should reset to zero.

---

### dtimer.stop(node_id, [reset])

Stops the timer attached to a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `[reset]`: `bool` if the timer should reset to zero.

---

### dtimer.toggle(node_id, [reset])

Toggles the timer attached to a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `[reset]`: `bool` if the timer should reset to zero.

---

### dtimer.update(dt)

Updates all timers and displays. Should be called in the `update(self, dt)` function of your gui script.

#### Parameters
1. `dt`: Time elapsed since last frame.

---

### dtimer.set_url(url)

Sets the url of the gui script to receive `dtimer` messages.

#### Parameters
1. `url`: Url of the gui script to receive `dtimer` messages.

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

### dtimer.set_direction(node_id, increasing, [duration])

Sets the timer direction of a node.

#### Parameters
1. `node_id`: Hashed id of a gui node.
2. `increasing`: `bool` if timer should count up or down.
3. `[duration]`: Maximum elapsed seconds counting up from zero or start time counting down to zero. This argument is required if `increasing` is `false`.

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
