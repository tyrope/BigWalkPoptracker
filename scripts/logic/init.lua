require("scripts.logic.ruleparser")

SLOT_LOGIC = nil
ID_LOOKUP_TABLE = {}

function FetchSlotLogic(slot_data)
    SLOT_LOGIC = slot_data["logic"]
end

function LookupSlotLocation(locID)
    if ID_LOOKUP_TABLE[locID] == nil then
        -- Either the table is empty or we're not in it, do the expensive lookup.
        for _, loc in pairs(SLOT_LOGIC["locations"]) do
            if loc[2] == 0 then
                goto skipWrongLoc
            elseif LOCATION_MAPPING[loc[2]][1] == locID then
                ID_LOOKUP_TABLE[locID] = loc
                break
            end
            ::skipWrongLoc::
        end
        if ID_LOOKUP_TABLE[locID] == nil then
            -- We tried, but couldn't find ourselves, mark as unavailable.
            ID_LOOKUP_TABLE[locID] = -1
        end
    end
    if ID_LOOKUP_TABLE[locID] == -1 then
        -- We don't have an associated slot location.
        return nil
    end
    return ID_LOOKUP_TABLE[locID]
end

function LoadTrackerJson()
    -- TODO Detemine which layout to load.
    --Tracker:AddLayouts("layouts/trackers/core.json")
    --Tracker:AddLayouts("layouts/trackers/core-light.json")
    --Tracker:AddLayouts("layouts/trackers/core-object.json")
    Tracker:AddLayouts("layouts/trackers/core-light-object.json")
end

function LoadLocationsJsons()
    -- TODO Only load locations based on the layout loaded.
    Tracker:AddLocations("locations/Core.json")
    Tracker:AddLocations("locations/Lightsanity.json")
    Tracker:AddLocations("locations/Objectsanity.json")
end

function ParseAccess(locID)
    -- AccessibilityLevel.None          - Red
    -- AccessibilityLevel.NoPriority    - Red
    -- AccessibilityLevel.Inspect       - Blue
    -- AccessibilityLevel.Partial       - Yellow
    -- AccessibilityLevel.SequenceBreak - Yellow
    -- AccessibilityLevel.Normal        - Green
    loc_obj = Tracker:FindObjectForCode(locID)
    if loc_obj == nil then
        print("[BigWalk] ERR: ParseAccess("..locID..") => Input parsed as nil!")
        return nil
    end
    if SLOT_LOGIC == nil or loc_obj.AccessibilityLevel == AccessibilityLevel.Cleared then
        -- Don't touch logic if we're not connected, and don't unclear cleared checks.
        return loc_obj.AccessibilityLevel
    end
    slot_loc = LookupSlotLocation(locID)
    if slot_loc == nil then
        print("[BigWalk] DEBUG: Could not map "..locID.." to a slot location.")
        return AccessibilityLevel.Inspect
    end
    rules = SLOT_LOGIC["rules"][slot_loc[4]+1]
    if rules == nil then
        print("[BigWalk] ERR: Rules for "..slot_loc[1].."not found, somehow?")
        return AccessibilityLevel.Inspect
    end
    parsedRule = ParseRule(rules)
    if parsedRule then
        return AccessibilityLevel.Normal
    else
        return AccessibilityLevel.None
    end
end

Archipelago:AddClearHandler("InitialLogic", FetchSlotLogic)

