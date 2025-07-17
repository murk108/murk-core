local total_lines = 0

function print(str)
    total_lines = total_lines + 1
    local current_line = total_lines

    Scheduler:schedule(1, function ()
        game.print(current_line .. ": " .. tostring(str))
        return false
    end)
end

function create_error_handler(prepend_error, return_value)
    return function(error)
        game.print(prepend_error .. debug.traceback(tostring(error), 1))
        return return_value
    end
end

function normal_call(callback, placeholder_arg, ...)
    return true, callback(...) -- first arg for compat with xpcall
end
