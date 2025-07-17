---@type TimeWheel
local M = {}
M.__index = M

function M.create(max_buckets, safe_mode)
    local buckets = {}

    for i = 1, max_buckets do
        buckets[i] = {}
    end

    local obj = {
        max_buckets = max_buckets,
        buckets = buckets,
        snapshot_bucket = {},

        call = safe_mode and xpcall or normal_call,

        blacklisted = {},
        future_ticks = {},

        listeners = {},

        current_index = 1,
        tick = 1
    }

    return setmetatable(obj, M)
end

function M:clear()
    local buckets = self.buckets

    for i = 1, self.max_buckets do
        buckets[i] = {}
    end

    self.snapshot_bucket = {}
    self.blacklisted = {}
    self.future_ticks = {}
    self.listeners = {}
    self.current_index = 1
    self.tick = 1
end

function M:create_listener(max_buckets)
    local listener = M.create(max_buckets)
    local listeners = self.listeners
    listeners[#listeners+1] = listener
    return listener
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
    return callback
end

function M:remove(callback)
    self.blacklisted[callback] = true
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
local function take_snapshot(self, index)
    local snapshot_bucket = self.snapshot_bucket
    local bucket = self.buckets[index]
    local size = #bucket

    for i = 1, size do
        snapshot_bucket[i] = bucket[i]
        bucket[i] = nil
    end

    return snapshot_bucket, bucket, size
end

local handler = create_error_handler("Time wheel error: ", false)
function M:cycle()
    cycle_listeners(self)

    local tick = self.tick
    local current_index = self.current_index
    local future_ticks = self.future_ticks
    local blacklisted = self.blacklisted

    local snapshot_bucket, curr_bucket, size = take_snapshot(self, current_index)

    local call = self.call

    for i = 1, size do
        local callback = snapshot_bucket[i]
        local blocked = blacklisted[callback]

        if blocked then
            goto continue
        end

        if tick >= future_ticks[callback] then -- is due
            local _, delay = call(callback, handler)
            blocked = blacklisted[callback] -- incase the callback calls remove on itself

            if delay ~= false and not blocked then
                if delay == nil or delay == true or delay <= 0 then
                    delay = 1
                end

                re_schedule(self, delay, callback)
            else
                blacklisted[callback] = nil
                future_ticks[callback] = nil
            end
        else
            curr_bucket[#curr_bucket+1] = callback -- not ready then pack back
        end

        ::continue::
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
            callback(start, length) -- handle the remaining
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