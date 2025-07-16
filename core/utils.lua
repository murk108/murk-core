local print_cache = {"[CORE LOG] "}
local print_scheduled = false
local print_delay = 10

function print(str)
    print_cache[#print_cache+1] = str

    if not print_scheduled then
        Scheduler:schedule(print_delay, function()
            game.print(table.concat(print_cache, "\n"))

            print_cache = {"[CORE LOG] "}
            print_scheduled = false
            return false
        end)

        print_scheduled = true
    end
end

function create_error_handler(prepend_error, return_value)
    return function(error)
        game.print(prepend_error .. debug.traceback(tostring(error), 1))
        return return_value
    end
end