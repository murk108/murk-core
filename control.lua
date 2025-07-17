require("core.utils")

------------------------

Events = require("core.event_defines")
GameEvents = defines.events

-----------------

local time_wheel = require("core.objects.time_wheel")
local hooker = require("core.objects.hooker")

local safe_mode = false -- for performance

Scheduler = time_wheel.create(4096, safe_mode)
Hooker = hooker.create(safe_mode)
InputHooker = hooker.create(safe_mode)

--------------------

require("core.generic_events")

----------------------

get_entity = require("core.handlers.entity_handler")
get_group_id = require("core.handlers.blueprint_handler")

require("core.handlers.gui_handler")
require("core.handlers.input_handler")
require("core.handlers.tick_handler")

----------------

require("core.load_mods")
