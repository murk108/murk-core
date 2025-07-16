require("core.utils")

------------------------

Events = require("core.event_defines")
GameEvents = defines.events

-----------------

Scheduler = require("core.objects.time_wheel").create(4096)

-------------------

local hooker = require("core.objects.hooker")
Hooker = hooker.create()
InputHooker = hooker.create()

--------------------

require("core.generic_events")

----------------------

get_entity = require("core.handlers.entity_handler")
get_group_id = require("core.handlers.blueprint_handler")

require("core.handlers.gui_handler")
require("core.handlers.input_handler")
require("core.handlers.tick_handler")
require("core.handlers.hook_handler")

----------------

require("core.load_mods")
