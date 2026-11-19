require("scripts.lib.stringrecipes")

SLOT_VIS_DATA = {}

----- Mostly locations, but also triggers items. -----
function SetSlotVisData(slot_data)
    -- Gourd deposit count.
    if slot_data["deposit_locations"] == "all" then
        SLOT_VIS_DATA["@Core/Gourd Deposit/Count"] = true
        SLOT_VIS_DATA["@Core/Gourd Deposit/Count/item_count"] = 45
    elseif slot_data["deposit_locations"] == "milestones" then
        SLOT_VIS_DATA["@Core/Gourd Deposit/Count"] = true
        SLOT_VIS_DATA["@Core/Gourd Deposit/Count/item_count"] = 9
    elseif slot_data["deposit_locations"] == "none" then
        SLOT_VIS_DATA["@Core/Gourd Deposit/Count"] = false
    else
        print("[BigWalk] ERROR: SetSlotVisData::Invalid value for slot_data[\"deposit_locations\"]")
    end

    -- Radio stations.
    for i=1,7 do
        SLOT_VIS_DATA["@Core/Radio Station 0"..i.."/On"] = slot_data["radio_station_checks"]
    end

    -- Pack Sanity.
    SetSlotVisRange({"Sky Blue Backpack","Yellow Backpack","Teal Backpack",
        "Orange Backpack","Pink Backpack","Maroon Backpack","Green Belt",
        "Purple Belt","Yellow Belt","Orange Belt","Blue Belt","Gourd Carton"},
    "@Core/", "/Collected", slot_data["pack_sanity"] ~= false)

    -- Firework Sanity
    SetSlotVisRange({"Hub","Red Funnel Tower", "Yellow Twist Tower",
        "Blue Castle Tower","Green Cup Tower","Peak","South Peak",
        "Intro Platform"}, "@Core/", "/Fireworks", slot_data["firework_sanity"])

    -- Flare gun sanity
    SetSlotVisRange({"Red","Green","Yellow","Blue"}, "@Core/",
        " Flare Gun/Pickup", slot_data["flare_gun_sanity"])

    -- Purple gourd puzzles.
    for _,v in ipairs({"Cabin Fever Long", "Centurion Seance", "Speed Obby",
        "Dancer and Selector", "Charades Rooms", "Poet and Pontiff",
        "Cannonball Commute"}) do
        SLOT_VIS_DATA["@Core/"..v.."/Puzzle"] = slot_data["include_big_game_puzzles"] ~= "disabled"
    end

    -- Gauntlet
    SLOT_VIS_DATA["@Core/Gauntlet"] = slot_data["gauntlet_mode"] == "locked_stages"

    SetSlotVisMonuments(slot_data) -- Monuments
    SetSlotVisObjectsanity(slot_data) -- Objectsanity

    SetLocationVisibilities(slot_data) -- Location layouts
    SetItemVisibilities(slot_data) -- Item Layouts
end

----- LOCATIONS -----

function SetSlotVisRange(checkArray, loc_prefix, loc_suffic, visible)
    for _,v in ipairs(checkArray) do
        SLOT_VIS_DATA[loc_prefix..v..loc_suffic] = visible
    end
end

function SetSlotVisMonuments(slot_data)
    slotkeynames = {
        bigKeyIntro="Drawbridge",
        bigKeyRedZone="Red Funnel Tower",
        bigKeyGreenZone="Green Cup Tower",
        bigKeyBlueZone="Blue Castle Tower",
        bigKeyYellowZone="Yellow Twist Tower",
        bigKeyBoss="Black Monolith Tower",
        bigKeyOverflow="Green Dome Tower"
    }
    for key, v in pairs(slotkeynames) do
        -- Monument Key
        SLOT_VIS_DATA["@Core/"..v.."/Monument Key"] = false
        for _, entry in pairs(slot_data["monument_key_keys"]) do
            if entry == key then
                SLOT_VIS_DATA["@Core/"..v.."/Monument Key"] = true
                break
            end
        end

        -- Monument Full
        SLOT_VIS_DATA["@Core/"..v.."/Monument Full"] = false
        for _, entry in pairs(slot_data["monument_full_keys"]) do
            if entry == key then
                SLOT_VIS_DATA["@Core/"..v.."/Monument Full"] = true
                break
            end
        end

        -- Reached
        SLOT_VIS_DATA["@Core/"..v.."/Reached"] = false
        for _, entry in pairs(slot_data["tower_reached_keys"]) do
            if entry == key then
                SLOT_VIS_DATA["@Core/"..v.."/Reached"] = true
                break
            end
        end
    end

    for _,v in ipairs({"Drawbridge", "Red Funnel Tower", "Green Cup Tower", "Blue Castle Tower", "Yellow Twist Tower"}) do
        -- Key Cut 1-5
        for i=1,5 do
            SLOT_VIS_DATA["@Core/"..v.."/Key Cut "..i] = slot_data["cut_key_sanity"]
        end
    end

end

function SetSlotVisObjectsanity(slot_data)
    allItems = {"binoculars","clock","compass","cowbell","lamp","laser","map",
        "megaphone","radio","scanner","torch","walkie_talkie","paintbrush"}
    objSan = slot_data["object_sanity"]

    sanItemMapping = {}
    for _, item in ipairs(allItems) do
        sanItemMapping[item] = false
        for _, san in pairs(slot_data["object_sanity_kind_keys"]) do
            if san == item then
                sanItemMapping[item] = true
                break
            end
        end
    end

    -- Set the "first pickup" locations on @Core:
    for _,i in ipairs(allItems) do
        if i == "walkie_talkie" then
            items = {"Walkie-Talkie"}
        elseif i == "lamp" then
            items = {"Lamp", "Red Lamp", "Pedestal Lamp"}
        elseif i == "cowbell" then
            items = {"Small Cowbell", "Medium Cowbell", "Large Cowbell"}
        elseif i == "map" then
            items = {"Folding Map"}
        else
            items = {i:gsub("^%l", string.upper)}
        end
        for _, item in ipairs(items) do
            isVis = sanItemMapping[i] and objSan == "first_pickup"
            if slot_data["light_sanity"] ~= "off" and (
                item == "Lamp" or item == "Red Lamp" or item == "Pedestal Lamp"
            ) then
                -- Doesn't count if lightsanity!
                isVis = false
            end
            SLOT_VIS_DATA["@Core/First "..item.."/Pickup"] = isVis and objSan == "first_pickup"
        end
    end

    -- @Objectsanity, here be dragons.
    for _, loc in pairs(LOCATION_MAPPING) do
        loc = loc[1]
        if string_starts_with(loc, "@Objectsanity") == false then
            -- Not an objectsanity.
            goto continueForLoc
        end
        if string_ends_with(loc,"Held") then
            -- Some form of lamp. It's visibility is the inverse of light sanity.
            SLOT_VIS_DATA[loc] = slot_data["light_sanity"] == "off" and sanItemMapping["lamp"]

        elseif string_ends_with(loc,{"1","2","3"}) then
            -- Surprise! MapRoom is an exception that has 3 lasers, at least we know it's a laser.
            SLOT_VIS_DATA[loc] = sanItemMapping["laser"]

        elseif string_ends_with(loc,"Pickup") then
            -- One of @Objectsanity/Item (Location)/Pickup
            name = string_split(loc,"/")[2] -- Item (Location)
            name = string.lower(string_split(name," ")[1]) -- item
            name = string.gsub(name,"-","_") -- Walkies wanna be special
            SLOT_VIS_DATA[loc] = sanItemMapping[name]
        else
            -- Probably ending in an item name. Time to split the string.
            name = string_split(loc,"/")[3]
            name = string.lower(name)
            if sanItemMapping[name] ~= nil then
                SLOT_VIS_DATA[loc] = sanItemMapping[name]
            else
                -- Folding Map or (Small/Medium/Large) Cowbell, we want the second word.
                name = string_split(name, " ")[2]
                SLOT_VIS_DATA[loc] = sanItemMapping[name]
            end
        end
        ::continueForLoc::
    end
end

function SetLocationVisibilities(slot_data)
    layout = "core"
    if slot_data["light_sanity"] ~= "off" then
        layout = layout .. "-light"
    end
    if slot_data["object_sanity"] == "every" then
        layout = layout .. "-object"
    end
    Tracker:AddLayouts("layouts/maps/"..layout..".json")
end

----- ITEMS -----

function SetSlotVisZonelock(slot_data)
    lamps = false
    gadgets = false

    -- Object sanity is on.
    if slot_data["object_sanity"] ~= "off" then
        for _, v in pairs(slot_data["object_sanity_kind_keys"]) do
            if v == "lamp" then
                lamps = true -- And we need lamps!
            else
                gadgets = true -- And we need a non-lamp!
            end
        end
    end

    -- lamps also become part of the equation if lightsanity isn't off.
    lamps = lamps or slot_data["light_sanity"] ~= "off"

    return {lamps, gadgets}
end

function FindDoorItemJson(slot_data)
    doorjson = ""

    for _,v in pairs(slot_data["locked_arch_doors"]) do
        if v == "SpawnHubGate" then
            doorjson = doorjson.."_first"
        elseif v == "HubShortcutToSportsCreek" then
            doorjson = doorjson.."_left"
        elseif v == "HubTunnel" then
            doorjson = doorjson.."_right"
        end
    end

    doorjson = doorjson:gsub("_left_right","_sides")

    -- This one shouldn't happen, but you never know...
    doorjson = doorjson:gsub("_right_left","_sides")

    if slot_data["gauntlet_mode"] == "locked_stages" then -- Gauntlet.
        if slot_data["gauntlet_stage_items"] == "progressive" then
            doorjson = doorjson.."_gauntProg"
        else
            doorjson = doorjson.."_gauntInd"
        end
    end
    if doorjson == "" then
        doorjson = "none"
    else -- Remove the starting underscore.
        doorjson = doorjson:sub(2)
    end
    return "layouts/items/doors/"..doorjson..".json"
end

function SetItemVisibilities(slot_data)
    -- Puzzle pieces
    if slot_data["lock_puzzle_needs"] then
        Tracker:AddLayouts("layouts/items/puzzle/enabled.json")
    else
        Tracker:AddLayouts("layouts/items/puzzle/disabled.json")
    end

    -- Radio Music.
    if slot_data["radio_station_items"] then
        Tracker:AddLayouts("layouts/items/radio/enabled.json")
    else
        Tracker:AddLayouts("layouts/items/radio/disabled.json")
    end

    Tracker:AddLayouts("layouts/items/keys.json")

    -- teleports. This might need tweaking?
    if slot_data["teleport_buttons"] == "items" then
        Tracker:AddLayouts("layouts/items/teleport/enabled.json")
    else
        Tracker:AddLayouts("layouts/items/teleport/disabled.json")
    end

    -- Doors.
    Tracker:AddLayouts(FindDoorItemJson(slot_data))

    -- Abilities
    if slot_data["lock_abilities"] == "disabled" then
        Tracker:AddLayouts("layouts/items/abilities/disabled.json")
    elseif slot_data["lock_abilites"] == "handed" then
        if slot_data["lock_running"] then
            Tracker:AddLayouts("layouts/items/abilities/handed_running.json")
        else
            Tracker:AddLayouts("layouts/items/abilities/handed.json")
        end
    else -- lock_abilities == ambidextrous
        if slot_data["lock_running"] then
            Tracker:AddLayouts("layouts/items/abilities/ambidextrous_running.json")
        else
            Tracker:AddLayouts("layouts/items/abilities/ambidextrous.json")
        end
    end

    zones = SetSlotVisZonelock(slot_data)
    if zones[1] and zones[2] then
        -- lamps and gadgets
        Tracker:AddLayouts("layouts/items/zonelocks/both.json")
    elseif zones[1] then
        -- only lamps
        Tracker:AddLayouts("layouts/items/zonelocks/lamps.json")
    elseif zones[2] then
        -- only gadgets
        Tracker:AddLayouts("layouts/items/zonelocks/gadgets.json")
    else
        -- Neither.
        Tracker:AddLayouts("layouts/items/zonelocks/disabled.json")
    end

    if slot_data["tunnel_sanity"] then
        Tracker:AddLayouts("layouts/items/core_tunnelsanity.json")
    else
        Tracker:AddLayouts("layouts/items/core.json")
    end
end


---- RUNTIME -----

function ParseVisible(locID)
    if SLOT_VIS_DATA[locID] ~= nil then
        return SLOT_VIS_DATA[locID]
    else
        print("[BigWalk] ERROR: ParseVisible::"..locID.." not in SLOT_VIS_DATA")
        return false
    end
end

Archipelago:AddClearHandler("InitialVisibility", SetSlotVisData)

