local keybinds = {}
local key_ids = {}

local core_input = "core_input"
local start_of_key_name = string.len(core_input) + 2

for name, id in pairs(GameEvents) do
    if string.find(name, core_input) then
        local key_name = string.gsub(string.sub(name, start_of_key_name), "_", " + ")

        keybinds[id] = key_name
        table.insert(key_ids, id)
    end
end

Hooker:add_multi_hook(key_ids, function (event)
    local player = game.get_player(event.player_index)
    local input_name = keybinds[event.name]
    InputHooker:trigger_hook(input_name, player)
end)