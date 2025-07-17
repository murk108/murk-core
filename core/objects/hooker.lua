---@type Hooker
local M = {}
M.__index = M

function M.create(safe_mode)
    local obj = {
        hooks = {},
        snapshot_hooks = {},
        call = safe_mode and xpcall or normal_call,

        blacklisted = {},
        listeners = {}
    }

    return setmetatable(obj, M)
end

function M:clear()
    self.hooks = {}
    self.snapshot_hooks = {}
    self.blacklisted = {}
    self.listeners = {}
end

function M:create_listener()
    local obj = M.create()
    local listeners = self.listeners
    listeners[#listeners+1] = obj

    return obj
end

function M:add_hook(name, callback)
    local hooks = self.hooks

    local callbacks = hooks[name] or {}
    hooks[name] = callbacks

    callbacks[#callbacks+1] = callback
    return callback
end

function M:add_multi_hook(names, callback)
    local add_hook = M.add_hook
    for i = 1, #names do
        add_hook(self, names[i], callback)
    end
end

function M:remove(callback)
    self.blacklisted[callback] = true
end

---@param self Hooker   
local function trigger_listeners(self, name, ...)
    local listeners = self.listeners
    local size = #listeners

    local trigger_hook = M.trigger_hook

    for i = 1, size do
        trigger_hook(listeners[i], name, ...)
    end
end

---@param self Hooker
local function take_snapshot(self, name)
    local snapshot = self.snapshot_hooks[name] or {}
    local callbacks = self.hooks[name]
    local size = #callbacks

    for i = 1, size do
        snapshot[i] = callbacks[i]
        callbacks[i] = nil
    end

    self.snapshot_hooks[name] = snapshot
    return snapshot, callbacks, size
end

local handler = create_error_handler("Callback error: ", false)
function M:trigger_hook(name, ...)
    trigger_listeners(self, name, ...)

    if not self.hooks[name] then
        return
    end

    local snapshot, callbacks, size = take_snapshot(self, name)
    local blacklisted = self.blacklisted

    local call = self.call

    for i = 1, size do
        local callback = snapshot[i]
        local blocked = blacklisted[callback]

        if not blocked then
            local _, result = call(callback, handler, ...)
            blocked = blacklisted[callback] -- incase the callback calls remove on itself

            if result ~= false and not blocked then
                callbacks[#callbacks+1] = callback
            else
                blacklisted[callback] = nil
            end
        end
    end
end

return M