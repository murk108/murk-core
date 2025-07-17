---@meta

--- In Factorio, Id is the unit_number of an entity. aka LuaEntity::unit_number
---@alias Id integer 

---@alias WheelResult integer | boolean | nil
---@alias HookerResult boolean | nil

---@alias WheelCallback fun() : WheelResult
---@alias HookerCallback fun(...) : HookerResult

---@class TimeWheel
---@field max_buckets integer
---@field buckets WheelCallback[][]
---@field call fun(callback : WheelCallback, handler : fun(error : string?), ... : any)
---@field snapshot_bucket WheelCallback[]
---@field blacklisted table<WheelCallback, boolean>
---@field listeners TimeWheel[]
---@field future_ticks table<WheelCallback, integer>
---@field current_index integer
---@field tick integer
local TimeWheel = {}

---@param max_buckets integer
---@return TimeWheel
function TimeWheel.create(max_buckets) end

--- creates a timewheel that listens to the cycles of the self
---@param max_buckets integer
---@return TimeWheel
function TimeWheel:create_listener(max_buckets) end

--- return integer for N tick delay.
--- return nothing for 1 tick delay.
--- return false to remove the hook.
---@param delay integer the initial delay in ticks
---@param callback WheelCallback
---@return WheelCallback callback
function TimeWheel:schedule(delay, callback) end

--- removes the callback
---@param callback WheelCallback
function TimeWheel:remove(callback) end

---@param length integer iterates from [1, length] over time
---@param chunks integer splits length into N chunks
---@param delay integer delay between each chunk
---@param callback fun(start : integer, end : integer) callback of the current chunk
function TimeWheel:split_run(length, chunks, delay, callback) end

function TimeWheel:cycle() end

function TimeWheel:clear() end

---@class Hooker
---@field hooks table<any, HookerCallback[]>
---@field snapshot_hooks table<any, HookerCallback[]>
---@field call fun(callback : HookerCallback, handler : fun(error : string?), ... : any)
---@field blacklisted table<HookerCallback, boolean>
---@field listeners Hooker[]
local Hooker = {}

---@return Hooker
function Hooker.create() end

--- creates a hooker that listens to all of the self's hooks
---@return Hooker
function Hooker:create_listener() end

--- return false in the callback to remove the callback.
--- return nothing in the callback to do nothing.
---@overload fun(self: Hooker, name : "on_spawned", callback : fun(entity : LuaEntity, tags : table<string, any>) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_died", callback : fun(entity : LuaEntity) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_load", callback : fun() : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_setup_blueprint", callback : fun(player : LuaPlayer, bp_entities : BlueprintEntity[], stack : LuaItemStack, mappings : table<integer, LuaEntity>) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_create_main_gui", callback : fun(player : LuaPlayer, core_main_gui : LuaGuiElement) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_closed_main_gui", callback : fun(player : LuaPlayer, core_main_gui : LuaGuiElement) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_wire_connect", callback : fun(graph : WireGraph, id_a : integer, id_b : integer) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_wire_disconnect", callback : fun(graph : WireGraph, id_a : integer, id_b : integer) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_marker_set_name", callback : fun(marker_id : integer, name : string) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : "on_marker_died", callback : fun(marker_id : integer) : HookerResult) : HookerCallback
---@overload fun(self: Hooker, name : any, callback : HookerCallback) : HookerCallback
function Hooker:add_hook(name, callback) end

--- removes the callback
---@param callback HookerCallback
function Hooker:remove(callback) end

--- return false in the callback to remove the callback.
--- return nothing in the callback to do nothing.
---@param names any[]
---@param callback HookerCallback
function Hooker:add_multi_hook(names, callback) end

---@param name any
---@param ... any custom arguments
function Hooker:trigger_hook(name, ...) end

function Hooker:clear() end