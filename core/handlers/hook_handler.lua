local cleanup_all_hookers = Hooker.cleanup_all_hookers

Scheduler:schedule(1, function ()
    cleanup_all_hookers()
    return 60
end)