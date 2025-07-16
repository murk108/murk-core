local function is_missing_file(error)
    return string.find(error, "no such file") or string.find(error, "does not match any enabled mod")
end

local function try_require(path)
    local ok, error = pcall(require, path)

    if not ok then
        if is_missing_file(error) then
            print("Continuing without optional mod: " .. path)
        else
            print("Loading Error: " .. error)
        end
    else
        print("Loaded: " .. path)
    end
end

-- optional mods
try_require("__scriptorio__.main")
try_require("__murk-wire-system__.main")