---@type TimeWheel
local M = {}
M.__index = M

function M.create(max_buckets)
    local buckets = {}

    for i = 1, max_buckets do
        buckets[i] = {}
    end

    local obj = {
        max_buckets = max_buckets,
        buckets = buckets,
        snapshot_bucket = {},
        future_ticks = {},
        listeners = {},
        current_index = 1,
        tick = 1
    }

    return setmetatable(obj, M)
end

function M:create_listener(max_buckets)
    local listener = M.create(max_buckets)
    local listeners = self.listeners
    listeners[#listeners+1] = listener
    return listener
end

function M:clear()
    local buckets = self.buckets

    for i = 1, self.max_buckets do
        buckets[i] = {}
    end

    self.future_ticks = {}
end

---@param self TimeWheel
local function re_schedule(self, delay, callback)
    local future_tick = self.tick + delay
    local future_index = (future_tick - 1) % self.max_buckets + 1
    local future_bucket = self.buckets[future_index]

    future_bucket[#future_bucket+1] = callback
    self.future_ticks[callback] = future_tick
end

function M:schedule(delay, callback)
    if delay <= 0 then
        delay = 1
    end

    re_schedule(self, delay, callback)
end

---@param self TimeWheel   
local function cycle_listeners(self)
    local listeners = self.listeners
    local n = #listeners
    local cycle = M.cycle

    for i = 1, n do
        cycle(listeners[i])
    end
end

---@param self TimeWheel
---@return WheelCallback[], integer
local function get_snapshot(self, curr_bucket)
    local snapshot_bucket = self.snapshot_bucket
    local bucket_length = #curr_bucket

    for i = 1, bucket_length do
        snapshot_bucket[i] = curr_bucket[i]
        curr_bucket[i] = nil
    end

    return snapshot_bucket, bucket_length
end

local handler = create_error_handler("Time wheel error: ", false)
function M:cycle()
    cycle_listeners(self)

    local tick = self.tick
    local current_index = self.current_index
    local future_ticks = self.future_ticks

    local curr_bucket = self.buckets[current_index]
    local snapshot_bucket, bucket_length = get_snapshot(self, curr_bucket)

    for i = 1, bucket_length do
        local callback = snapshot_bucket[i]

        if tick >= future_ticks[callback] then -- is due
            local _, delay = xpcall(callback, handler)

            if delay ~= false then
                if delay == nil or delay == true or delay <= 0 then
                    delay = 1
                end

                re_schedule(self, delay, callback)
            else -- remove
                future_ticks[callback] = nil
            end
        else
            curr_bucket[#curr_bucket+1] = callback -- not ready then pack back
        end
    end

    self.tick = tick + 1
    self.current_index = current_index % self.max_buckets + 1
end

function M:split_run(length, chunks, delay, callback)
    local dx = math.floor(length / chunks)
    local i = 1

    M.schedule(self, delay, function()
        local start = (i - 1) * dx + 1

        if i == chunks then
            callback(start, length) -- handle the remainding
            return false
        else
            local last = start + dx - 1
            callback(start, last)

            i = i + 1
            return delay
        end
    end)
end

return M