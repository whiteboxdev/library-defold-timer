----------------------------------------------------------------------
-- LICENSE
----------------------------------------------------------------------

-- MIT License

-- Copyright (c) 2022 Klayton Kowalski

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- https://github.com/klaytonkowalski/defold-timer

----------------------------------------------------------------------
-- PROPERTIES
----------------------------------------------------------------------

local dtimer = {}

dtimer.messages =
{
	start = hash("dtimer_start"),
	stop = hash("dtimer_stop")
}

local nodes = {}

local on_message_url

local hour_scalar = 1 / 60 / 60
local minute_scalar = 1 / 60

----------------------------------------------------------------------
-- LOCAL FUNCTIONS
----------------------------------------------------------------------

local function get_timestamp(elapsed)
	return
	{
		hours = math.floor(elapsed * hour_scalar),
		minutes = math.floor(elapsed * minute_scalar % 60),
		seconds = math.floor(elapsed % 60),
		centiseconds = math.floor(elapsed * 100 % 100)
	}
end

local function get_timestamp_components(elapsed)
	return math.floor(elapsed * hour_scalar), math.floor(elapsed * minute_scalar % 60), math.floor(elapsed % 60), math.floor(elapsed * 100 % 100)
end

local function draw(node)
	local text = ""
	local hours, minutes, seconds, centiseconds = get_timestamp_components(node.elapsed)
	if node.format.hours then
		text = text .. hours
	else
		minutes = minutes + hours * 60
	end
	if node.format.minutes then
		if #text > 0 then
			text = text .. ":"
			if minutes < 10 then
				text = text .. "0"
			end
		end
		text = text .. minutes
	else
		seconds = seconds + minutes * 60
	end
	if node.format.seconds then
		if #text > 0 then
			text = text .. ":"
			if seconds < 10 then
				text = text .. "0"
			end
		end
		text = text .. seconds
	else
		centiseconds = centiseconds + seconds * 60
	end
	if node.format.centiseconds then
		if #text > 0 then
			text = text .. "."
			if centiseconds < 10 then
				text = text .. "0"
			end
		end
		text = text .. centiseconds
	end
	gui.set_text(node.node, text)
end

local function reset_node(node)
	if node.increasing then
		node.elapsed = 0
	else
		node.elapsed = node.duration
	end
end

----------------------------------------------------------------------
-- MODULE FUNCTIONS
----------------------------------------------------------------------

function dtimer.add_node(node_id, increasing, format, duration)
	if not nodes[node_id] then
		nodes[node_id] =
		{
			node = gui.get_node(node_id),
			enabled = false,
			elapsed = not increasing and duration or 0,
			increasing = increasing,
			format = format or { minutes = true, seconds = true },
			duration = duration
		}
	end
end

function dtimer.remove_node(node_id)
	nodes[node_id] = nil
end

function dtimer.start(node_id, reset)
	local node = nodes[node_id]
	if node then
		node.enabled = true
		if reset then
			reset_node(node)
		end
		msg.post(on_message_url, dtimer.messages.start, { node_id = node_id, elapsed = node.elapsed })
	end
end

function dtimer.stop(node_id, reset)
	local node = nodes[node_id]
	if node then
		node.enabled = false
		msg.post(on_message_url, dtimer.messages.stop, { node_id = node_id, elapsed = node.elapsed, complete = node.elapsed == (node.increasing and node.duration or 0) })
		if reset then
			reset_node(node)
		end
	end
end

function dtimer.toggle(node_id, reset)
	if nodes[node_id] then
		if nodes[node_id].enabled then
			return dtimer.stop(node_id, reset)
		end
		return dtimer.start(node_id, reset)
	end
end

function dtimer.update(dt)
	for node_id, node in pairs(nodes) do
		if node.enabled then
			if node.increasing then
				node.elapsed = node.elapsed + dt
				if node.duration and node.duration < node.elapsed then
					node.elapsed = node.duration
					node.enabled = false
					msg.post(on_message_url, dtimer.messages.stop, { node_id = node_id, elapsed = node.elapsed, complete = true })
				end
			else
				node.elapsed = node.elapsed - dt
				if node.elapsed < 0 then
					node.elapsed = 0
					node.enabled = false
					msg.post(on_message_url, dtimer.messages.stop, { node_id = node_id, elapsed = node.elapsed, complete = true })
				end
			end
		end
		draw(node)
	end
end

function dtimer.set_url(url)
	on_message_url = url
end

function dtimer.set_format(node_id, format)
	if nodes[node_id] then
		nodes[node_id].format = format
	end
end

function dtimer.set_timestamp(node_id, format, seconds)
	draw({ node = gui.get_node(node_id), format = format, elapsed = seconds })
end

function dtimer.get_elapsed(node_id)
	if nodes[node_id] then
		return nodes[node_id].elapsed
	end
end

function dtimer.get_timestamp(node_id)
	if nodes[node_id] then
		return get_timestamp(nodes[node_id].elapsed)
	end
end

function dtimer.is_enabled(node_id)
	if nodes[node_id] then
		return nodes[node_id].enabled
	end
end

return dtimer
