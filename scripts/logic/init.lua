require("scripts.logic.ruleparser")

SLOT_LOGIC = nil

function FetchSlotLogic(slot_data)
    SLOT_LOGIC = slot_data["logic"]
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
    for _, loc in pairs(SLOT_LOGIC["locations"]) do
        if loc[2] == 8600300 and locID == "@Core/Drawbridge/Monument Key" then
            print("[BigWalk] DBG: Drawbridge key ID: "..loc_obj.FullID)
            print("[BigWalk] DBG: location ID 8600300 in the SLOT_LOGIC is.. "..loc[1])
            print("[BigWalk] DBG: Which maps to..."..LOCATION_MAPPING[loc[2]][1])
        end
        if loc[2] == 0 then
            goto skipWrongLoc
        elseif LOCATION_MAPPING[loc[2]][1] ~= locID then
            goto skipWrongLoc
        end
        rules = SLOT_LOGIC["rules"][loc[4]+1]
        parsedRule = ParseRule(rules)
        if parsedRule then
            return AccessibilityLevel.Normal
        else
            return AccessibilityLevel.None
        end
        ::skipWrongLoc::
    end
    print("[BigWalk] ERR: ID for "..locID.." not found.")
    return AccessibilityLevel.Inspect
end

Archipelago:AddClearHandler("InitialLogic", FetchSlotLogic)

