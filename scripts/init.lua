local variant = Tracker.ActiveVariantUID

-- Libs
require("scripts.lib.recent_items.init")
require("scripts.lib.status_bar.init")

-- Locations
Tracker:AddLocations("locations/Core.json")
Tracker:AddLocations("locations/Lightsanity.json")
Tracker:AddLocations("locations/Objectsanity.json")

-- Items
Tracker:AddItems("items/items.json")

-- Maps
Tracker:AddMaps("maps/maps.json")

-- Logic
require("scripts.logic.logicEntry")
require("scripts.logic.visibility")

-- Layout
Tracker:AddLayouts("layouts/broadcast.json")
Tracker:AddLayouts("layouts/settings_popup.json")
Tracker:AddLayouts("layouts/maps/blank.json")
Tracker:AddLayouts("layouts/tracker.json")

-- AutoTracking for PopTracker
if PopVersion and PopVersion >= "0.26.0" then
    require("scripts.autotracking")
end

function OnFrameHandler()
    ScriptHost:RemoveOnFrameHandler("load handler")
    -- stuff
    ScriptHost:AddWatchForCode("StateChanged", "*", StateChanged)
    ScriptHost:AddOnLocationSectionChangedHandler("location_section_change_handler", LocationHandler)
    CreateLuaManualStorageItem("manual_location_storage")
    ForceUpdate()
end
require("scripts.luaitems")
require("scripts.watches")
ScriptHost:AddOnFrameHandler("load handler", OnFrameHandler)
