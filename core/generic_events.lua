local generic_events = {}

for name, event_id in pairs(GameEvents) do
    table.insert(generic_events, event_id)
end

script.on_event(generic_events, function (event)
    Hooker:trigger_hook(event.name, event)
end)