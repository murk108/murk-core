local modifiers = { -- generated
    {"CONTROL"},
    {"SHIFT"},
    {"ALT"},

    {"CONTROL", "SHIFT"},
    {"SHIFT", "CONTROL"},
    {"CONTROL", "ALT"},
    {"ALT", "CONTROL"},
    {"SHIFT", "ALT"},
    {"ALT", "SHIFT"},

    {"CONTROL", "SHIFT", "ALT"},
    {"CONTROL", "ALT", "SHIFT"},
    {"SHIFT", "CONTROL", "ALT"},
    {"SHIFT", "ALT", "CONTROL"},
    {"ALT", "CONTROL", "SHIFT"},
    {"ALT", "SHIFT", "CONTROL"},
}

local keybinds = {
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "mouse-button-1", "mouse-button-2", "mouse-button-3", "mouse-button-4", "mouse-button-5"
}

local function create(name, mods)
    local key_name
    local key_sequence

    if mods then
        key_name = table.concat(mods, "_") .. "_" .. name
        key_sequence = table.concat(mods, " + ") .. " + " .. name
    else
        key_name = name
        key_sequence = name
    end

    return {
        type = "custom-input",
        name = "core_input_" .. key_name,
        key_sequence = key_sequence,
        block_modifiers = false
    }
end

local keybind_events = {}

for i = 1, #keybinds do
    local bind = keybinds[i]
    table.insert(keybind_events, create(bind))

    for j = 1, #modifiers do
        local mods = modifiers[j]
        table.insert(keybind_events, create(bind, mods))
    end
end

data:extend(keybind_events)