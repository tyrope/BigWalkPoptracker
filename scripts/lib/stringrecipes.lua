-- CREDIT: http://lua-users.org/wiki/StringRecipes
-- Slightly modified from the above source.
function string_starts_with(str, start)
    return str:sub(1, #start) == start
end

local function tchelper(first, rest)
    return first:upper()..rest:lower()
end

function string_title_case(text)
    return text:gsub("(%a)([%w_']*)", tchelper)
end

function string_ends_with(str, ending)
    if type(ending) == "string" then
        return ending == "" or str:sub(-#ending) == ending
    else
        for _, e in ipairs(ending) do
            if string_ends_with(str,e) == true then
                return true
            end
        end
        return false
    end
end

-- CREDIT: http://lua-users.org/wiki/SplitJoin
-- Slightly modified from the above source.
function string_split(sFullstring, sSeparator, nMax, bRegexp)
   assert(sSeparator ~= '')
   assert(nMax == nil or nMax >= 1)

   local aRecord = {}

   if sFullstring:len() > 0 then
      local bPlain = not bRegexp
      nMax = nMax or -1

      local nField, nStart = 1, 1
      local nFirst,nLast = sFullstring:find(sSeparator, nStart, bPlain)
      while nFirst and nMax ~= 0 do
         aRecord[nField] = sFullstring:sub(nStart, nFirst-1)
         nField = nField+1
         nStart = nLast+1
         nFirst,nLast = sFullstring:find(sSeparator, nStart, bPlain)
         nMax = nMax-1
      end
      aRecord[nField] = sFullstring:sub(nStart)
   end

   return aRecord
end

function string_contains(fullstring, substr)
    return string.find(fullstring,substr) ~= nil
end
