-- this is the file to put all your custom logic functions into.
-- if you dont want to use the json based logic you can switch to a graph-based logic method.
-- the needed functions for that are in `/scripts/logic/graph_logic/logic_main.lua`.

SLOT_LOGIC = nil

function LogicPrep(slot_data)
    SLOT_LOGIC = slot_data["logic"]
    locOne = SLOT_LOGIC["locations"][1]
    locName = locOne[1]
    locID = locOne[2]
    print("--------- OVER HERE --------")
    print("Location 1's name:" .. locName)
    print("Location 1's ID:" .. locID)
    print("Which maps to...")
    print(LOCATION_MAPPING[locID][0])
end

Archipelago:AddClearHandler("LogicPrep", LogicPrep)
