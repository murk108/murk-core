local loaded = false
Hooker:add_hook(GameEvents.on_tick, function ()
    if not loaded then
        loaded = true
        Hooker:trigger_hook(Events.on_load)
    end

    Scheduler:cycle()
end)