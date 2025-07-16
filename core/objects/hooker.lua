---@type Hooker
local M = {}
M.__index = M

---@type Hooker[]
local hookers = {}

---@param self Hooker
local function remove_all_pending(self)
    local to_remove_hooks = self.to_remove_hooks
    local hooks = self.hooks

    for name, to_remove in pairs(to_remove_hooks) do
        local callbacks = hooks[name]

        local n = #callbacks
        local write_index = 0

        for i = 1, n do
            if not to_remove[i] then
                write_index = write_index + 1
                callbacks[write_index] = callbacks[i]
            end
        end

        for i = write_index + 1, n do
            callbacks[i] = nil
        end

        to_remove_hooks[name] = nil
    end
end

---@param self Hooker   
local function trigger_listeners(self, name, ...)
    local listeners = self.listeners
    local n = #listeners
    local trigger_hook = M.trigger_hook

    for i = 1, n do
        trigger_hook(listeners[i], name, ...)
    end
end

function M.create()
    local obj = {
        hooks = {},
        to_remove_hooks = {},
        listeners = {}
    }

    hookers[#hookers+1] = obj
    return setmetatable(obj, M)
end

function M.cleanup_all_hookers()
    for i = 1, #hookers do
        remove_all_pending(hookers[i])
    end
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
end

function M:add_multi_hook(names, callback)
    local add_hook = M.add_hook
    for i = 1, #names do
        add_hook(self, names[i], callback)
    end
end

function M:clear()
    self.hooks = {}
    self.to_remove_hooks = {}
    self.listeners = {}
end

local handler = create_error_handler("Callback error: ", false)
function M:trigger_hook(name, ...)
    trigger_listeners(self, name, ...)

    local callbacks = self.hooks[name]

    if not callbacks or #callbacks <= 0 then
        return
    end

    local size = #callbacks
    local to_remove = self.to_remove_hooks[name]

    for i = 1, size do
        if not to_remove or not to_remove[i] then
            local _, result = xpcall(callbacks[i], handler, ...)

            if result == false then
                to_remove = to_remove or {}
                to_remove[i] = true
            end
        end
    end

    self.to_remove_hooks[name] = to_remove
end

return M