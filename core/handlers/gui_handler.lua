local gui_interaction_events = {
    GameEvents.on_gui_click,
    GameEvents.on_gui_selection_state_changed,
    GameEvents.on_gui_text_changed,
    GameEvents.on_gui_value_changed
}

Hooker:add_multi_hook(gui_interaction_events, function (event)
    local element = event.element
    local element_name = element.name

    local player = game.get_player(event.player_index)

    Hooker:trigger_hook("on_gui_" .. element_name, player, element, event)
end)

-------------------------- opening the main gui

---@param player LuaPlayer
InputHooker:add_hook("G", function (player)
    if player.opened ~= nil then
        return
    end

    local gui = player.gui.screen

    if not gui.core_main_gui then
        local core_main_gui = gui.add{type = "frame", direction = "horizontal", name = "core_main_gui", caption = "Core Gui"}
        Hooker:trigger_hook("on_create_main_gui", player, core_main_gui)
        core_main_gui.force_auto_center()
    else
        local core_main_gui = gui.core_main_gui
        Hooker:trigger_hook("on_closed_main_gui", player, core_main_gui)
        core_main_gui.destroy()
    end
end)