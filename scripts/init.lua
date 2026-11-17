local variant = Tracker.ActiveVariantUID

-- Libs
require("scripts.lib.recent_items.init")
require("scripts.lib.status_bar.init")

-- Items
Tracker:AddItems("items/items.json")

-- Maps
Tracker:AddMaps("maps/maps.json")

-- Logic
require("scripts.logic.init")

-- Layout
Tracker:AddLayouts("layouts/broadcast.json")
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/settings_popup.json")
LoadTrackerJson() -- from scripts.logic

-- Locations
LoadLocationsJsons() -- from scripts.logic

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
