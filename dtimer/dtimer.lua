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

local function draw(data)
	local timestamp = get_timestamp(data.elapsed)
	local text = ""
	if data.format.hours then
		text = text .. timestamp.hours
	end
	if data.format.minutes then
		if data.format.hours then
			text = text .. ":"
			if timestamp.minutes < 10 then
				text = text .. "0"
			end
		end
		text = text .. timestamp.minutes
	end
	if data.format.seconds then
		if (data.format.hours or data.format.minutes) then
			text = text .. ":"
			if timestamp.seconds < 10 then
				text = text .. "0"
			end
		end
		text = text .. timestamp.seconds
	end
	if data.format.centiseconds then
		if (data.format.hours or data.format.minutes or data.format.seconds) then
			text = text .. ":"
			if timestamp.centiseconds < 10 then
				text = text .. "0"
			end
		end
		text = text .. timestamp.centiseconds
	end
	gui.set_text(data.node, text)
end

----------------------------------------------------------------------
-- MODULE FUNCTIONS
----------------------------------------------------------------------

function dtimer.add_node(node_id, increasing, format, duration)
	if not nodes[node_id] then
		nodes[node_id] = { node = gui.get_node(node_id), enabled = false, elapsed = not increasing and duration or 0, increasing = increasing, format = format or { minutes = true, seconds = true }, duration = duration }
	end
end

function dtimer.remove_node(node_id)
	if nodes[node_id] then
		nodes[node_id] = nil
	end
end

function dtimer.start(node_id, reset)
	if nodes[node_id] then
		nodes[node_id].enabled = true
		if reset then
			if nodes[node_id].increasing then
				nodes[node_id].elapsed = 0
			else
				nodes[node_id].elapsed = nodes[node_id].duration
			end
		end
		if on_message_url then
			msg.post(on_message_url, dtimer.messages.start, { node_id = node_id, elapsed = nodes[node_id].elapsed })
		end
	end
end

function dtimer.stop(node_id, reset)
	if nodes[node_id] then
		nodes[node_id].enabled = false
		if on_message_url then
			msg.post(on_message_url, dtimer.messages.stop, { node_id = node_id, elapsed = nodes[node_id].elapsed, complete = nodes[node_id].elapsed == (nodes[node_id].increasing and nodes[node_id].duration or 0) })
		end
		if reset then
			if nodes[node_id].increasing then
				nodes[node_id].elapsed = 0
			else
				nodes[node_id].elapsed = nodes[node_id].duration
			end
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
	for node_id, data in pairs(nodes) do
		if data.enabled then
			if data.increasing then
				data.elapsed = data.elapsed + dt
				if data.duration and data.duration < data.elapsed then
					data.elapsed = data.duration
					data.enabled = false
					if on_message_url then
						msg.post(on_message_url, dtimer.messages.stop, { node_id = node_id, elapsed = data.elapsed, complete = true })
					end
				end
			else
				data.elapsed = data.elapsed - dt
				if data.elapsed < 0 then
					data.elapsed = 0
					data.enabled = false
					if on_message_url then
						msg.post(on_message_url, dtimer.messages.stop, { node_id = node_id, elapsed = data.elapsed, complete = true })
					end
				end
			end
		end
		draw(data)
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

function dtimer.set_direction(node_id, increasing, duration)
	if nodes[node_id] then
		nodes[node_id].increasing = increasing
		nodes[node_id].duration = duration
	end
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