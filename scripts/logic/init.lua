SLOT_LOGIC = nil

-- ----- HELPERS START HERE -----

-- "Borrowed" from scripts\autotracking\archipelago.lua.
function DumpTable(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. DumpTable(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

-- Thank you StackOverflow: https://stackoverflow.com/a/2705804
function TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- ----- RULE PARSING STARTS HERE -----

function ParseAndOr(method, rules)
    if method == "and" then
        exitValue = false
    elseif method == "or" then
        exitValue = true
    else
        print("Wrong method for ParseMultiple.")
        return nil
    end

    for i=1,TableLength(rules) do
        if ParseRule(rules[i]) == exitValue then
            return exitValue
        end
    end
    return exitValue == false
end

function ParseHas(item, count)
    -- DEBUG: This is broken, the string we're getting isn't
    -- a valid FindObjectForCode input.
    item_obj = Tracker:FindObjectForCode(item)
    return item_obj.AcquiredCount >= count
end

function ParseItems(method, items, count)
    -- DEBUG: This is broken, the string we're getting isn't
    -- a valid FindObjectForCode input.
    for key,value in pairs(items) do
        amount = Tracker:FindObjectForCode(value).AcquiredCount
        if method == "all" and amount == 0 then
            return false
        elseif method == "any" and amount > 0 then
            return true
        elseif method == "from" and amount > 0 then
            count = count - 1
            if count == 0 then
                return true
            end
        end
    end
    if method == "all" then
        return true
    elseif method == "any" or method == "from" then
        return false
    end
end

function ParseLocation(loc)
    -- TODO
    return true
end

function ParseRegion(loc)
    -- TODO
    return true
end

-- Definitions provided at https://github.com/Grizfreak/BigWalk-archipelago/blob/master/apworld/README.md
function ParseRule(rule)
    -- ["true"] / ["false"] => always / never
    if rule[1] == "true" then
        return true
    elseif rule[1] == "false" then
        return false

    -- ["and", [rules]] / ["or", [rules]] => all / any of the rules
    elseif rule[1] == "and" or rule[1] == "or" then
        return ParseAndOr(rule[1], rule[2])

    -- ["has", item, count] => at least count of item received
    elseif rule[1] == "has" then
        return ParseHas(rule[2],rule[3])
    -- ["all", [items]] / ["any", [items]] => one of each / one of any
    elseif rule[1] == "all" or rule[1] == "any" then
        return ParseItems(rule[1], rule[2], nil)
    -- ["from", [items], count] => at least count items in total among the list
    elseif rule[1] == "from" then
        return ParseItems(rule[1], rule[2], rule[3])

    -- ["loc", location] => that location is reachable (its region and its rule)
    elseif rule[1] == "loc" then
        return ParseLocation(rule[2])
    -- ["reg", region] => that region is reachable
    elseif rule[1] == "reg" then
        return ParseRegion(rule[2])
    end
end

-- ----- EXECUTION STARTS HERE -----

function ParseLogicRules(slot_data)
    print("--------- OVER HERE --------")
    SLOT_LOGIC = slot_data["logic"]
    loc_amount = TableLength(SLOT_LOGIC["locations"])
    print("Number of loaded locations: " .. loc_amount)
    for i=1,loc_amount do
        loc = SLOT_LOGIC["locations"][i]
        rules = SLOT_LOGIC["rules"][i]
        parsedRule = ParseRule(rules)
        if parsedRule then
            access = "Yes"
        else
            access = "No"
        end
        print("AP name: " .. loc[1] .. " maps to "..LOCATION_MAPPING[loc[2]][1]..". Acccessible: " .. access)
    end
    print("--------- TEST DONE --------")
end

-- TODO Is this even the correct handler to listen to?
Archipelago:AddClearHandler("ParseLogicRules", ParseLogicRules)
