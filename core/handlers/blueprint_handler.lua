local total_clicks = 0
local position_ids = {}

local function get_position_id(entity)
    local id = entity.unit_number
    local position_id = position_ids[id]

    if not position_id then
        local pos = entity.position
        position_id = pos.x .. ", " .. pos.y
        position_ids[id] = position_id
    end

    return position_id
end

local function get_group_id(unit_number)
    local ent = get_entity(unit_number)
    return storage.group_ids[get_position_id(ent)]
end

Hooker:add_hook(Events.on_load, function ()
    ---@type table<string, integer>
    storage.group_ids = storage.group_ids or {}
    return false
end)

Hooker:add_hook(GameEvents.on_player_setup_blueprint, function (event)
    if not event.mapping.valid then
        return
    end

    local player = game.get_player(event.player_index)
    local stack = player.cursor_stack

    if not stack or not stack.valid_for_read then
        return
    end

    local bp_entities = stack.get_blueprint_entities()

    if not bp_entities then
        return
    end

    local mappings = event.mapping.get()
    Hooker:trigger_hook(Events.on_setup_blueprint, player, bp_entities, stack, mappings)
end)

Hooker:add_hook(Events.on_spawned, function (entity, tags)
    if entity.name == "entity-ghost" then
        storage.group_ids[get_position_id(entity)] = game.tick
    elseif game.tick_paused then
        storage.group_ids[get_position_id(entity)] = total_clicks -- breaks when player holds left click in editor mode!
    end
end)

Hooker:add_hook(Events.on_died, function (entity)
    storage.group_ids[get_position_id(entity)] = nil
end)

InputHooker:add_hook("mouse-button-1", function (player)
    total_clicks = total_clicks + 1 -- artbitary way to track blueprint groups
end)

return get_group_id