SLOT_VIS_DATA = {}

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

    -- Radio stations and music.
    for i=1,7 do
        SLOT_VIS_DATA["@Core/Radio Station 0"..i.."/On"] = slot_data["radio_station_checks"]
        SLOT_VIS_DATA["radiomusic0"..i] = slot_data["radio_station_items"]
    end

    -- Monuments
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

    -- Pack Sanity.
    for _,v in ipairs({"Sky Blue Backpack","Yellow Backpack","Teal Backpack",
        "Orange Backpack","Pink Backpack","Maroon Backpack","Green Belt",
        "Purple Belt","Yellow Belt","Orange Belt","Blue Belt","Gourd Carton"}) do
        SLOT_VIS_DATA["@Core/"..v.."/Collected"] = (slot_data["pack_sanity"] ~= false)
    end

    -- Firework Sanity
    for _,v in ipairs({"Hub","Red Funnel Tower", "Yellow Twist Tower","Blue Castle Tower",
        "Green Cup Tower","Peak","South Peak","Intro Platform"}) do
        SLOT_VIS_DATA["@Core/"..v.."/Fireworks"] = slot_data["firework_sanity"]
    end

    for _,v in ipairs({"Drawbridge", "Red Funnel Tower", "Green Cup Tower", "Blue Castle Tower", "Yellow Twist Tower"}) do
        -- Key Cut 1-5
        for i=1,5 do
            SLOT_VIS_DATA["@Core/"..v.."/Key Cut "..i] = slot_data["cut_key_sanity"]
        end
    end

    -- Flare gun sanity
    for _,v in ipairs({"Red","Green","Yellow","Blue"}) do
        SLOT_VIS_DATA["@Core/"..v.." Flare Gun/Pickup"] = slot_data["flare_gun_sanity"]
    end

    SetSlotVisObjectsanity(slot_data)
    SetSlotVisZonelock(slot_data)

    -- Tunnel Sanity
    SLOT_VIS_DATA["tunnels"] = (slot_data["tunnel_sanity"] == false)
    for _,v in ipairs({"redtunneldoor","greentunneldoor","bluetunneldoor","yellowtunneldoor","purpletunnel"}) do
        SLOT_VIS_DATA[v] = slot_data["tunnel_sanity"]
    end

    -- Lock puzzle needs
    for _,v in ipairs({"buttons","synchronizedbuttons","iconpanels","drawingpanels",
        "posepanels","soundpanels","speakers","lights","teapots",
        "timedtomato","golfball","bigheadmask","inkviewer","counter",
        "coordinatescomputer","terrainpegs"}) do
        SLOT_VIS_DATA[v] = slot_data["lock_puzzle_needs"]
    end

    -- Map room is special.
    SLOT_VIS_DATA["maproom"] = slot_data["start_with_map_room_open"]

    -- Purple gourd puzzles.
    for _,v in ipairs({"Cabin Fever Long", "Centurion Seance", "Speed Obby",
        "Dancer and Selector", "Charades Rooms", "Poet and Pontiff",
        "Cannonball Commute"}) do
        SLOT_VIS_DATA["@Core/"..v.."/Puzzle"] = slot_data["include_big_game_puzzles"] ~= "disabled"
    end

    -- Gauntlet
    gauntLock = slot_data["gauntlet_mode"] == "locked_stages"
    gauntProg = slot_data["gauntlet_stage_items"] == "progressive"
    SLOT_VIS_DATA["@Core/Gauntlet"] = gauntLock
    SLOT_VIS_DATA["progressivegauntletdoor"] = gauntLock and gauntProg
    for i=1,7 do
        SLOT_VIS_DATA["progressivestage"..i.."door"] = gauntLock and (gauntProg == false)
    end

    -- Arch doors
    SLOT_VIS_DATA["firstarchdoor"] = false
    SLOT_VIS_DATA["leftarchdoor"] = false
    SLOT_VIS_DATA["righttarchdoor"] = false
    for _, v in pairs(slot_data["locked_arch_doors"]) do
        if v == "SpawnHubGate" then
            SLOT_VIS_DATA["firstarchdoor"] = true
        elseif v == "HubShortcutToSportsCreek" then
            SLOT_VIS_DATA["leftarchdoor"] = true
        elseif v == "HubTunnel" then
            SLOT_VIS_DATA["rightarchdoor"] = true
        else
            print("[BigWalk] ERROR: SetSlotVisData::Unknown locked arch door in slot:"..v)
        end
    end

    -- Abilities
    ability = slot_data["lock_abilities"]
    SLOT_VIS_DATA["legs"] = ability ~= "disabled"
    SLOT_VIS_DATA["seat"] = ability ~= "disabled"
    SLOT_VIS_DATA["throwing"] = ability ~= "disabled"
    SLOT_VIS_DATA["carrying"] = ability ~= "disabled"

    SLOT_VIS_DATA["progressiveleftarm"] = ability == "handed"
    SLOT_VIS_DATA["progressiverighttarm"] = ability == "handed"
    SLOT_VIS_DATA["progressivearma"] = ability == "ambidextrous"

    SLOT_VIS_DATA["running"] = ability ~= "disabled" and slot_data["lock_running"]

    -- Layout & Locations
    layout = "core"
    Tracker:AddLocations("locations/Core.json")
    if slot_data["light_sanity"] ~= "off" then
        layout = layout .. "-light"
        Tracker:AddLocations("locations/Lightsanity.json")
    end
    if slot_data["object_sanity"] == "every" then
        layout = layout .. "-object"
        Tracker:AddLocations("locations/Objectsanity.json")
    end
    Tracker:AddLayouts("layouts/trackers/"..layout..".json")

    -- TODO: Item layouts.
end

function SetSlotVisObjectsanity(slot_data)
    allItems = {"binoculars","clock","compass","cowbell","lamp","laser","map",
        "megaphone","radio","scanner","torch","walkie_talkie","paintbrush"}
    objSan = slot_data["objest_sanity"]

    sanItemMapping = {}
    for _, item in ipairs(allItems) do
        sanItemMapping[item] = false
        for _, san in pairs(slot_data["object_sanity_kind_keys"]) do
            sanItemMapping[item] = true
            break
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
end

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

    -- Set the zones.
    for _,colour in ipairs({"red","green","blue","yellow"}) do
        SLOT_VIS_DATA[colour.."zonelamps"] = lamps
        SLOT_VIS_DATA[colour.."zonegadgets"] = gadgets
    end
end

function ParseVisible(locID)
    if SLOT_VIS_DATA[locID] ~= nil then
        return SLOT_VIS_DATA[locID]
    else
        print("[BigWalk] ERROR: ParseVisible::"..locID.." not in SLOT_VIS_DATA")
        return false
    end
end

Archipelago:AddClearHandler("InitialVisibility", SetSlotVisData)

