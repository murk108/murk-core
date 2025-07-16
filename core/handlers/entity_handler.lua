local on_spawned_events = {
    GameEvents.on_built_entity,
    GameEvents.on_robot_built_entity,
    GameEvents.script_raised_built,
    GameEvents.script_raised_revive,
    GameEvents.on_entity_cloned,
    GameEvents.on_entity_spawned,
}

local on_died_events = {
    GameEvents.on_player_mined_entity,
    GameEvents.on_robot_mined_entity,
    GameEvents.script_raised_destroy,
    GameEvents.on_entity_died
}

local function get_entity(unit_number)
    local ent = storage.entities[unit_number]
    assert(ent ~= nil, "Unit number does not exist!")
    return ent
end

Hooker:add_hook(Events.on_load, function ()
    ---@type table<Id, LuaEntity>
    storage.entities = storage.entities or {}
    return false
end)

Hooker:add_multi_hook(on_spawned_events, function (event)
    local ent = event.entity

    if ent.unit_number then
        local tags = event.tags
        storage.entities[ent.unit_number] = ent

        Hooker:trigger_hook(Events.on_spawned, ent, tags)
    end
end)

Hooker:add_multi_hook(on_died_events, function (event)
    local ent = event.entity

    if ent.unit_number then
        storage.entities[ent.unit_number] = nil

        Hooker:trigger_hook(Events.on_died, ent)
    end
end)

return get_entity