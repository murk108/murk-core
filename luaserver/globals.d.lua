---@meta

--- Custom events
---@enum Events
Events = {
    on_spawned = "on_spawned",
    on_died = "on_died",
    on_load = "on_load",
    on_setup_blueprint = "on_setup_blueprint",
    on_create_main_gui = "on_create_main_gui",
    on_closed_main_gui = "on_closed_main_gui",
    on_wire_connect = "on_wire_connect",
    on_wire_disconnect = "on_wire_disconnect",
    on_marker_set_name = "on_marker_set_name",
    on_marker_died = "on_marker_died"
}

--- Factorio's events
GameEvents = defines.events

--- Main hooker
---@type Hooker
Hooker = {}

--- Hooks onto inputs. Valid events are like "A", "B", "mouse-button-1", etc. Case sensitive!
---@type Hooker
InputHooker = {}

---@type TimeWheel
Scheduler = {}

---@generic T
---@param prepend_error string
---@param return_value T
---@return fun(error : string?) : T
create_error_handler = function (prepend_error, return_value) end

---@param id Id aka LuaEntity::unit_number
---@return LuaEntity entity
get_entity = function(id) end

---@param id Id aka LuaEntity::unit_number
---@return integer group_id id that seperates different pastes from each other
get_group_id = function(id) end

--- mimics xpcall in structure, but the call is unprotected
---@param callback fun(...) : any
---@return boolean success
---@return any result
function normal_call(callback, placeholder_arg, ...) end
